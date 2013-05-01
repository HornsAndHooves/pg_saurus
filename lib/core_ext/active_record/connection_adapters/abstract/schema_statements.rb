module ActiveRecord
  module ConnectionAdapters # :nodoc:
    module SchemaStatements # :nodoc:
      # Regexp used to find the function name and function argument of a
      # function call
      FUNCTIONAL_INDEX_REGEXP = /(\w+)\(((?:'.+'(?:::\w+)?, *)*)(\w+)\)/

      # Adds a new index to the table.  +column_name+ can be a single Symbol, or
      # an Array of Symbols.
      #
      # ====== Creating a partial index
      #  add_index(:accounts, [:branch_id, :party_id], :using => 'BTree'
      #   :unique => true, :concurrently => true, :where => 'active')
      # generates
      #  CREATE UNIQUE INDEX CONCURRENTLY
      #   index_accounts_on_branch_id_and_party_id
      #  ON
      #    accounts(branch_id, party_id)
      #  WHERE
      #    active
      #
      def add_index(table_name, column_name, options = {})
        name, type, creation_method, columns, opts = add_index_options(table_name, column_name, options)

        # GOTCHA:
        #   It ensures that there is no existing index only for the case when the index
        #   is created concurrently to avoid changing the error behavior for default
        #   index creation.
        #   -- zekefast 2012-09-25
        # GOTCHA:
        #   This check prevents invalid index creation, so after migration failed
        #   here there is no need to go to database and clean it from invalid
        #   indexes. But note that this handles only one of the cases when index
        #   creation can fail!!! All other case should be procesed manually.
        #   -- zekefast 2012-09-25
        if options.has_key?(:concurrently) && index_exists?(table_name, column_name, options)
          raise ::PgPower::IndexExistsError, "Index #{name} for `#{table_name}.#{column_name}` " \
            "column can not be created concurrently, because such index already exists."
        end

        sql = ["CREATE #{type} INDEX"]
        sql << creation_method.to_s
        sql << quote_column_name(name)
        sql << "ON #{quote_table_name(table_name)}"
        sql << "USING #{options[:using].to_s.downcase}" if options[:using]
        sql << "(#{columns})#{opts}"

        execute sql.join(" ")
      end

      # Checks to see if an index exists on a table for a given index definition.
      #
      # === Examples
      #  # Check that a partial index exists
      #  index_exists?(:suppliers, :company_id, :where => 'active')
      #
      #  # GIVEN: 'index_suppliers_on_company_id' UNIQUE, btree (company_id) WHERE active
      #  index_exists?(:suppliers, :company_id, :unique => true, :where => 'active') => true
      #  index_exists?(:suppliers, :company_id, :unique => true) => false
      #
      def index_exists?(table_name, column_name, options = {})
        column_names = Array.wrap(column_name)
        index_name = options.key?(:name) ? options[:name].to_s : index_name(table_name, :column => column_names)

        # Always compare the index name
        default_comparator = lambda { |index| index.name == index_name }
        comparators = [default_comparator]

        # Add a comparator for each index option that is part of the query
        index_options = [:unique, :where]
        index_options.each do |index_option|
          comparators << if options.key?(index_option)
            lambda do |index|
              pg_where_clause = index.send(index_option)
              # pg does nothing to boolean clauses, e.g. 'where active' => 'where active'
              if pg_where_clause.is_a?(TrueClass) or pg_where_clause.is_a?(FalseClass)
                pg_where_clause == options[index_option]
              else
                # pg adds parentheses around non-boolean clauses, e.g. 'where color IS NULL' => 'where (color is NULL)'
                pg_where_clause.gsub!(/[()]/,'')
                # pg casts string comparison ::text. e.g. "where color = 'black'" => "where ((color)::text = 'black'::text)"
                pg_where_clause.gsub!(/::text/,'')
                # prevent case from impacting the comparison
                pg_where_clause.downcase == options[index_option].downcase
              end
            end
          else
            # If the given index_option is not an argument to the index_exists? query,
            # select only those pg indexes that do not have the component
            lambda { |index| index.send(index_option).blank? }
          end
        end

        # Search all indexes for any that match all comparators
        indexes(table_name).any? do |index|
          comparators.inject(true) { |ret, comparator| ret && comparator.call(index) }
        end
      end

      # Derives the name of the index from the given table name and options hash.
      def index_name(table_name, options) #:nodoc:
        if Hash === options # legacy support
          if options[:column]
            column_names = Array.wrap(options[:column]).map {|c| expression_index_name(c)}
            "index_#{table_name}_on_#{column_names * '_and_'}"
          elsif options[:name]
            options[:name]
          else
            raise ArgumentError, "You must specify the index name"
          end
        else
          index_name(table_name, :column => options)
        end
      end

      # Returns options used to build out index SQL
      #
      # Added support for partial indexes implemented using the :where option
      #
      def add_index_options(table_name, column_name, options = {})
        column_names          = Array(column_name)
        index_name            = index_name(table_name, :column => column_names)
        index_creation_method = nil

        if Hash === options # legacy support, since this param was a string
          index_type = options[:unique] ? 'UNIQUE' : ''
          index_creation_method = options[:concurrently] ? 'CONCURRENTLY' : ''
          index_name = options[:name].to_s if options.key?(:name)
          if supports_partial_index?
            index_options = options[:where] ? " WHERE #{options[:where]}" : ''
          end
        else
          index_type = options
        end

        if index_name.length > index_name_length
          raise ArgumentError, "Index name '#{index_name}' on table '#{table_name}' is too long; the limit is #{index_name_length} characters"
        end
        if index_name_exists?(table_name, index_name, false)
          raise ArgumentError, "Index name '#{index_name}' on table '#{table_name}' already exists"
        end
        index_columns = quoted_columns_for_index(column_names, options).join(', ')

        [index_name, index_type, index_creation_method, index_columns, index_options]
      end
      protected :add_index_options

      # Override super method to provide support for expression column names
      def quoted_columns_for_index(column_names, options = {})
        column_names.map do |name|
          if name =~ FUNCTIONAL_INDEX_REGEXP
            "#{$1}(#{$2}#{quote_column_name($3)})"
          else
            quote_column_name(name)
          end
        end
      end
      protected :quoted_columns_for_index

      # Map an expression to a name appropriate for an index
      def expression_index_name(column_name)
        if column_name =~ FUNCTIONAL_INDEX_REGEXP
          "#{$1.downcase}_#{$3}"
        else
          column_name
        end
      end
      private :expression_index_name
    end
  end
end
