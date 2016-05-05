module PgSaurus # :nodoc:
  # Provides methods to extend {ActiveRecord::ConnectionAdapters::PostgreSQLAdapter}
  # to support foreign keys feature.
  module ConnectionAdapters::PostgreSQLAdapter::ForeignKeyMethods

    # Drop table and optionally disable triggers.
    # Changes adapted from https://github.com/matthuhiggins/foreigner/blob/e72ab9c454c156056d3f037d55e3359cd972af32/lib/foreigner/connection_adapters/sql2003.rb
    # NOTE: Disabling referential integrity requires superuser access in postgres.
    #       Default AR behavior is just to drop_table.
    #
    # == Options:
    # * :force - force disabling of referential integrity
    #
    # Note: I don't know a good way to test this -mike 20120420
    def drop_table(*args)
      options = args.clone.extract_options!
      if options[:force]
        disable_referential_integrity { super }
      else
        super
      end
    end

    # See activerecord/lib/active_record/connection_adapters/abstract/schema_statements.rb
    # Creates index on the FK column by default. Pass in the option :exclude_index => true
    # to disable this.
    def add_foreign_key_with_index(from_table, to_table, options = {})
      exclude_index = (options.has_key?(:exclude_index) ? options.delete(:exclude_index) : false)
      column        = options[:column] || foreign_key_column_for(to_table)

      if index_exists?(from_table, column) && !exclude_index
        raise PgSaurus::IndexExistsError,
              "The index, #{index_name(from_table, column)}, already exists." \
          "  Use :exclude_index => true when adding the foreign key."
      end

      add_foreign_key_without_index from_table, to_table, options

      unless exclude_index
        add_index from_table, column
      end
    end

    # See activerecord/lib/active_record/connection_adapters/abstract/schema_statements.rb
    def remove_foreign_key_with_index(from_table, options_or_to_table = {})
      if options_or_to_table.is_a?(Hash) && options_or_to_table[:remove_index]
        column = options_or_to_table[:column]
        remove_index from_table, column
      end

      remove_foreign_key_without_index(from_table, options_or_to_table)
    end

    # See: activerecord/lib/active_record/connection_adapters/abstract/schema_statements.rb
    def foreign_key_column_for_with_schema(table_name)
      table = table_name.to_s.split('.').last

      foreign_key_column_for_without_schema table
    end

    # see activerecord/lib/active_record/connection_adapters/postgresql/schema_statements.rb
    def foreign_keys_with_schema(table_name)
      namespace  = table_name.to_s.split('.').first
      table_name = table_name.to_s.split('.').last

      namespace  = if namespace == table_name
                     "ANY (current_schemas(false))"
                   else
                     quote(namespace)
                   end

      sql = <<-SQL.strip_heredoc
            SELECT t2.oid::regclass::text AS to_table, a1.attname AS column, a2.attname AS primary_key, c.conname AS name, c.confupdtype AS on_update, c.confdeltype AS on_delete, t3.nspname AS from_schema
            FROM pg_constraint c
            JOIN pg_class t1 ON c.conrelid = t1.oid
            JOIN pg_class t2 ON c.confrelid = t2.oid
            JOIN pg_attribute a1 ON a1.attnum = c.conkey[1] AND a1.attrelid = t1.oid
            JOIN pg_attribute a2 ON a2.attnum = c.confkey[1] AND a2.attrelid = t2.oid
            JOIN pg_namespace t3 ON c.connamespace = t3.oid
            WHERE c.contype = 'f'
              AND t1.relname = #{quote(table_name)}
              AND t3.nspname = #{namespace}
            ORDER BY c.conname
      SQL

      fk_info = select_all(sql)

      fk_info.map do |row|
        options = {
          column:      row['column'],
          name:        row['name'],
          primary_key: row['primary_key'],
          from_schema: row['from_schema']
        }

        options[:on_delete] = extract_foreign_key_action(row['on_delete'])
        options[:on_update] = extract_foreign_key_action(row['on_update'])

        ::ActiveRecord::ConnectionAdapters::ForeignKeyDefinition.new(table_name, row['to_table'], options)
      end
    end


  end
end
