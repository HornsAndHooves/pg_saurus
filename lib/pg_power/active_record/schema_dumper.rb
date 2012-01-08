module ActiveRecord
  class SchemaDumper

    def dump(stream)
      header(stream)
      schemas(stream)
      tables(stream)
      trailer(stream)
      stream
    end


    # generates code to create schemas
    def schemas(stream)
      schema_names = PgPower::Tools.schemas - ["public", "information_schema"]
      schema_names.each do |schema|
        schema(schema, stream)
      end
      stream << "\n"
    end
    private :schemas

    # generates code to create schema
    def schema(schema_name, stream)
      stream << "  create_schema \"#{schema_name}\"\n"
    end
    public :schema

    # Returns array of table names from all schemas with schema dot prefix.
    def get_table_names
      table_names = []
      original_schema_search_path = @connection.schema_search_path

      schema_names = PgPower::Tools.schemas - ["information_schema"]
      schema_names.each do |schema_name|
        @connection.schema_search_path = schema_name
        @connection.tables.each do |table_name|
          table_names << "#{schema_name}.#{table_name}"
        end
      end

      @connection.schema_search_path = original_schema_search_path
      table_names
    end
    private :get_table_names

    # Generates code to create all tables from all schemas
    def tables(stream)
      get_table_names.each do |tbl|
        next if ['schema_migrations', ignore_tables].flatten.any? do |ignored|
          case ignored
          when String; tbl == ignored
          when Regexp; tbl =~ ignored
          else
            raise StandardError, 'ActiveRecord::SchemaDumper.ignore_tables accepts an array of String and / or Regexp values.'
          end
        end
        table(tbl, stream)
      end
    end
    private :tables
  end
end
