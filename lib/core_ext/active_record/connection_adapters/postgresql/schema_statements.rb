module ActiveRecord
  module ConnectionAdapters # :nodoc:
    module PostgreSQL # :nodoc:
      module SchemaStatements # :nodoc:
        # Regexp used to find the function name and function argument of a
        # function call:
        FUNCTIONAL_INDEX_REGEXP = /(\w+)\(((?:'.+'(?:::\w+)?, *)*)(\w+)\)/

        # Regexp used to find the operator name (or operator string, e.g. "DESC NULLS LAST"):
        OPERATOR_REGEXP = /(.+?)\s([\w\s]+)$/

        # Regex to find columns used in index statements
        INDEX_COLUMN_EXPRESSION = /ON [\w\.]+(?: USING \w+ )?\((.+)\)/

        # Regex to find where clause in index statements
        INDEX_WHERE_EXPRESSION = /WHERE (.+)$/

        # Returns the list of all tables in the schema search path or a specified schema.
        #
        # == Patch:
        # If current user is not `postgres` original method return all tables from all schemas
        # without schema prefix. This disables such behavior by querying only default schema.
        # Tables with schemas will be queried later.
        #
        def tables(name = nil)
          query(<<-SQL, 'SCHEMA').map { |row| row[0] }
              SELECT tablename
              FROM pg_tables
              WHERE schemaname = ANY (ARRAY['public'])
          SQL
        end

        # Returns an array of indexes for the given table.
        #
        # == Patch 1:
        # Remove type specification from stored Postgres index definitions.
        #
        # == Patch 2:
        # Split compound functional indexes to array.
        #
        def indexes(table_name)
          scope = quoted_scope(table_name)

          result = query(<<-SQL, "SCHEMA")
            SELECT distinct i.relname, d.indisunique, d.indkey, pg_get_indexdef(d.indexrelid), t.oid,
                            pg_catalog.obj_description(i.oid, 'pg_class') AS comment
            FROM pg_class t
            INNER JOIN pg_index     d  ON t.oid = d.indrelid
            INNER JOIN pg_class     i  ON d.indexrelid = i.oid
            LEFT JOIN  pg_namespace n  ON n.oid = i.relnamespace
            WHERE i.relkind = 'i'
              AND d.indisprimary = 'f'
              AND t.relname = #{scope[:name]}
              AND n.nspname = #{scope[:schema]}
            ORDER BY i.relname
          SQL

          result.map do |row|
            index_name = row[0]
            unique     = row[1]
            indkey     = row[2].split(" ").map(&:to_i)
            inddef     = row[3]
            oid        = row[4]
            comment    = row[5]

            using, expressions, where = inddef.scan(/ USING (\w+?) \((.+?)\)(?: WHERE (.+))?\z/m).flatten

            orders = {}
            opclasses = {}

            if indkey.include?(0)
              definition = inddef.sub(INDEX_WHERE_EXPRESSION, '')

              if column_expression = definition.match(INDEX_COLUMN_EXPRESSION)[1]
                columns = split_expression(expressions).map do |functional_name|
                  remove_type(functional_name)
                end

                columns = columns.size > 1 ? columns : columns[0]
              end
            else
              columns = Hash[query(<<-SQL.strip_heredoc, "SCHEMA")].values_at(*indkey).compact
                SELECT a.attnum, a.attname
                FROM pg_attribute a
                WHERE a.attrelid = #{oid}
                AND a.attnum IN (#{indkey.join(",")})
              SQL

              # add info on sort order (only desc order is explicitly specified, asc is the default)
              # and non-default opclasses
              expressions.scan(/(?<column>\w+)"?\s?(?<opclass>\w+_ops)?\s?(?<desc>DESC)?\s?(?<nulls>NULLS (?:FIRST|LAST))?/).each do |column, opclass, desc, nulls|
                opclasses[column] = opclass.to_sym if opclass
                if nulls
                  orders[column] = [desc, nulls].compact.join(" ")
                else
                  orders[column] = :desc if desc
                end
              end
            end

            IndexDefinition.new(
              table_name,
              index_name,
              unique,
              columns,
              orders:    orders,
              opclasses: opclasses,
              where:     where,
              using:     using.to_sym,
              comment:   comment.presence
            )
          end
        end

        # Redefine original add_index method to handle :concurrently option.
        #
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
          creation_method = options.delete(:concurrently) ? 'CONCURRENTLY' : nil

          # Whether to skip the quoting of columns. Used only for expressions like JSON indexes in which
          # the column is difficult to target for quoting.
          skip_column_quoting = options.delete(:skip_column_quoting) or false

          index_name,
          index_type,
          index_columns_and_opclasses,
          index_options,
          index_algorithm,
          index_using,
          comment = add_index_options(table_name, column_name, options)

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
          if creation_method.present? && index_exists?(table_name, column_name, options)
            raise ::PgSaurus::IndexExistsError,
                  "Index #{index_name} for `#{table_name}.#{column_name}` " \
                  "column can not be created concurrently, because such index already exists."
          end

          statements = []
          statements << "CREATE #{index_type} INDEX"
          statements << creation_method      if creation_method.present?
          statements << index_algorithm      if index_algorithm.present?
          statements << quote_column_name(index_name)
          statements << "ON"
          statements << quote_table_name(table_name)
          statements << index_using          if index_using.present?
          statements << "(#{index_columns_and_opclasses})" if index_columns_and_opclasses.present? unless skip_column_quoting
          statements << "(#{column_name})"   if column_name.present? and skip_column_quoting
          statements << index_options        if index_options.present?

          sql = statements.join(' ')

          execute(sql)
        end

        # Check to see if an index exists on a table for a given index definition.
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
          index_name = options.key?(:name) ? options[:name].to_s : index_name(table_name, column: column_names)

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

        # Derive the name of the index from the given table name and options hash.
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
            index_name(table_name, column: options)
          end
        end

        # Override super method to provide support for expression column names.
        def quoted_columns_for_index(column_names, **options)
          return [column_names] if column_names.is_a?(String)

          quoted_columns = Hash[
            column_names.map do |name|
              column_name, operator_name = split_column_name(name)

              result_name = if column_name =~ FUNCTIONAL_INDEX_REGEXP
                              _name = column_name.gsub(/\b#{$3}\b/, quote_column_name($3))
                              _name += " #{operator_name}"
                              _name
                            else
                              quote_column_name(column_name).dup
                            end
              [column_name.to_sym, result_name]
            end
          ]

          add_options_for_index_columns(quoted_columns, options).values
        end
        protected :quoted_columns_for_index

        # Map an expression to a name appropriate for an index.
        def expression_index_name(name)
          column_name, operator_name = split_column_name(name)

          result_name = if column_name =~ FUNCTIONAL_INDEX_REGEXP
                          "#{$1.downcase}_#{$3}"
                        else
                          column_name
                        end

          result_name += "_" + operator_name.parameterize.underscore if operator_name

          result_name
        end
        private :expression_index_name

        # Split column name to name and operator class if possible.
        def split_column_name(name)
          if name =~ OPERATOR_REGEXP
            return $1, $2
          else
            return name, nil
          end
        end
        private :split_column_name

        # Splits only on commas outside of parens
        def split_expression(expression)
          result = []
          parens = 0
          buffer = ""

          expression.chars do |char|
            case char
            when ','
              if parens == 0
                result.push(buffer)
                buffer = ""
                next
              end
            when '('
              parens += 1
            when ')'
              parens -= 1
            end

            buffer << char
          end

          result << buffer unless buffer.empty?
          result
        end
        private :split_expression

        # Remove type specification from stored Postgres index definitions
        #
        # @param [String] column_with_type the name of the column with type
        # @return [String]
        #
        # @example
        #   remove_type("((col)::text")
        #   => "col"
        def remove_type(column_with_type)
          column_with_type.sub(/\((\w+)\)::\w+/, '\1')
        end
        private :remove_type
      end
    end
  end
end
