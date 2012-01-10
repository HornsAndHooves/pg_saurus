module ActiveRecord
  # Creates dump of DB structure.
  # Patched methods::
  #   * dump
  #   * tables
  # New methods::
  #   * schemas
  #   * schema
  #   * get_table_names
  class SchemaDumper
    # Writes DB dump to stream.
    # Patch::
    #   add `schemas(stream)` line to create schemas as well.
    def dump(stream)
      header(stream)
      schemas(stream)
      tables(stream)
      trailer(stream)
      stream
    end

    # Generates code to create all tables from all schemas.
    # Patch reason: we need to process table from all schemas, not public only.
    # Patch::
    #   `@connection.tables.sort` replaced with `get_table_names`.
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

    # Generates code to create schemas.
    def schemas(stream)
      # Don't create "public" schema since it exists by default.
      schema_names = PgPower::Tools.schemas - ["public", "information_schema"]
      schema_names.each do |schema|
        schema(schema, stream)
      end
      stream << "\n"
    end
    private :schemas

    # Generates code to create schema.
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

  end
end
