module ActiveRecord
  module ConnectionAdapters # :nodoc:
    module SchemaStatements # :nodoc:

      # TODO write rdoc, determine if index_exists?, or any other methods need to be updated as well


      # Adds a new index to the table.  +column_name+ can be a single Symbol, or
      # an Array of Symbols.
      #
      # The index will be named after the table and the first column name,
      # unless you pass <tt>:name</tt> as an option.
      #
      # When creating an index on multiple columns, the first column is used as a name
      # for the index. For example, when you specify an index on two columns
      # [<tt>:first</tt>, <tt>:last</tt>], the DBMS creates an index for both columns as well as an
      # index for the first column <tt>:first</tt>. Using just the first name for this index
      # makes sense, because you will never have to create a singular index with this
      # name.
      #
      # ===== Examples
      #
      # ====== Creating a simple index
      #  add_index(:suppliers, :name)
      # generates
      #  CREATE INDEX suppliers_name_index ON suppliers(name)
      #
      # ====== Creating a unique index
      #  add_index(:accounts, [:branch_id, :party_id], :unique => true)
      # generates
      #  CREATE UNIQUE INDEX accounts_branch_id_party_id_index ON accounts(branch_id, party_id)
      #
      # ====== Creating a named index
      #  add_index(:accounts, [:branch_id, :party_id], :unique => true, :name => 'by_branch_party')
      # generates
      #  CREATE UNIQUE INDEX by_branch_party ON accounts(branch_id, party_id)
      #
      # ====== Creating an index with specific key length
      #  add_index(:accounts, :name, :name => 'by_name', :length => 10)
      # generates
      #  CREATE INDEX by_name ON accounts(name(10))
      #
      #  add_index(:accounts, [:name, :surname], :name => 'by_name_surname', :length => {:name => 10, :surname => 15})
      # generates
      #  CREATE INDEX by_name_surname ON accounts(name(10), surname(15))
      #
      # Note: SQLite doesn't support index length
      #
      # ====== Creating a partial index
      #  add_index(:accounts, [:branch_id, :party_id], :unique => true, :where => "active")
      # generates
      #  CREATE UNIQUE INDEX index_accounts_on_branch_id_and_party_id ON accounts(branch_id, party_id) WHERE active
      #
      def add_index(table_name, column_name, options = {})
        index_name, index_type, index_columns, index_options = add_index_options(table_name, column_name, options)
        execute "CREATE #{index_type} INDEX #{quote_column_name(index_name)} ON #{quote_table_name(table_name)} (#{index_columns})#{index_options}"
      end

      # TODO determine if this is protected/private
      def add_index_options(table_name, column_name, options = {})
        column_names = Array(column_name)
        index_name   = index_name(table_name, :column => column_names)

        if Hash === options # legacy support, since this param was a string
          index_type = options[:unique] ? "UNIQUE" : ""
          index_name = options[:name].to_s if options.key?(:name)
          if supports_partial_index?
            index_options = options[:where] ? " WHERE #{options[:where]}" : ""
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
        index_columns = quoted_columns_for_index(column_names, options).join(", ")

        [index_name, index_type, index_columns, index_options]
      end
      protected :add_index_options


    end
  end
end