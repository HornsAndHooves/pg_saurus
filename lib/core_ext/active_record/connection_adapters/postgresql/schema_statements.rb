module ActiveRecord
  module ConnectionAdapters # :nodoc:
    module PostgreSQL # :nodoc:
      module SchemaStatements # :nodoc:
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

        # == Patch 1:
        # Remove schema name part from table name when sequence name doesn't include it.
        def new_column_from_field(table_name, field, ...)
          column_name, type, default, notnull, oid, fmod, collation, comment = field
          type_metadata = fetch_type_metadata(column_name, type, oid.to_i, fmod.to_i)
          default_value = extract_value_from_default(default)
          default_function = extract_default_function(default_value, default)

          if match = default_function&.match(/\Anextval\('"?(?<sequence_name>.+_(?<suffix>seq\d*))"?'::regclass\)\z/)
            sequence_name = match[:sequence_name]
            is_schema_name_included = sequence_name.split(".").size > 1
            _table_name = is_schema_name_included ? table_name : table_name.split(".").last

            serial = sequence_name_from_parts(_table_name, column_name, match[:suffix]) == sequence_name
          end

          PostgreSQL::Column.new(
            column_name,
            default_value,
            type_metadata,
            !notnull,
            default_function,
            collation: collation,
            comment: comment.presence,
            serial: serial
          )
        end
        private :new_column_from_field

        # Don't separate schema from name.
        def index_name(...)
          super
        end

        # Somehow Rails got this wrong? Their setting is 62
        def max_index_name_size
          63
        end

        # Override to only check table name, not schema and table name.
        #
        # https://github.com/rails/rails/blob/v7.2.2.2/activerecord/lib/active_record/connection_adapters/abstract/schema_statements.rb#L1787
        def validate_table_length!(table_name)
          max_table_name_length = 64
          if table_name.to_s.split(".").last.length > max_table_name_length
            raise ArgumentError, <<~MSG.squish
              Table name '#{table_name}' is too long (#{table_name.length} characters); the limit is
              #{max_table_name_length} characters
            MSG
          end
        end
      end
    end
  end
end
