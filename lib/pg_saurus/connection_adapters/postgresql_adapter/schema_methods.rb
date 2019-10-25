# Provides methods to extend {ActiveRecord::ConnectionAdapters::PostgreSQLAdapter}
# to support schemas feature.
module PgSaurus::ConnectionAdapters::PostgreSQLAdapter::SchemaMethods
  # Move table to another schema
  # @param [String] table table name. Can be with schema prefix e.g. "demography.people"
  # @param [String] schema schema where table should be moved to.
  def move_table_to_schema(table, schema)
    ::PgSaurus::Tools.move_table_to_schema(table, schema)
  end

  # Create schema if it does not exist yet.
  #
  # @param schema_name [String]
  def create_schema_if_not_exists(schema_name)
    ::PgSaurus::Tools.create_schema_if_not_exists(schema_name)
  end

  # Drop schema if it exists.
  #
  # @param schema_name [String]
  def drop_schema_if_exists(schema_name)
    ::PgSaurus::Tools.drop_schema_if_exists(schema_name)
  end

  # Provide :schema option to +drop_table+ method.
  def drop_table(table_name, options = {})
    options     = options.dup
    schema_name = options.delete(:schema)
    table_name  = "#{schema_name}.#{table_name}" if schema_name
    super(table_name, options)
  end

  # Make method +tables+ return tables not only from public schema.
  #
  # @note
  #   Tables from public schema have no "public." prefix. It's done for
  #   compatibility with other libraries that relies on a table name.
  #   Tables from other schemas has appropriate prefix with schema name.
  #   See: https://github.com/TMXCredit/pg_power/pull/42
  #
  # @return [Array<String>] table names
  def tables(*args)
    tables = super(*args)
    quoted_table_names = tables.map{|t| "'#{t}'"}.join(",")

    query(<<-SQL, 'SCHEMA').map { |row| row[0] }
      SELECT
        CASE
          WHEN schemaname = 'public' THEN tablename
          ELSE schemaname || '.' || tablename
        END AS table
      FROM pg_tables
      WHERE tablename IN (#{quoted_table_names})
    SQL
  end

  # Provide :schema option to +rename_table+ method.
  def rename_table(table_name, new_name, options = {})
    schema_name = options[:schema]
    if schema_name
      in_schema schema_name do
        super(table_name, new_name)
      end
    else
      super(table_name, new_name)
    end
  end

  # Execute operations in the context of the schema
  def in_schema(schema_name)
    search_path = current_schema_search_path
    begin
      execute("SET search_path TO '%s'" % schema_name)
      yield
    ensure
      execute("SET search_path TO #{search_path};")
    end
  end

  # Reads the current schema search path (it may have been altered
  # from the initial value used when creating the connection)
  def current_schema_search_path
    select_value("SHOW search_path;")
  end

end
