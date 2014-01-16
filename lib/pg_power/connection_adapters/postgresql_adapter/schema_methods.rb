# Provides methods to extend {ActiveRecord::ConnectionAdapters::PostgreSQLAdapter}
# to support schemas feature.
module PgPower::ConnectionAdapters::PostgreSQLAdapter::SchemaMethods
  # Creates new schema in DB.
  # @param [String] schema_name
  def create_schema(schema_name)
    ::PgPower::Tools.create_schema(schema_name)
  end

  # Drops schema in DB.
  # @param [String] schema_name
  def drop_schema(schema_name)
    ::PgPower::Tools.drop_schema(schema_name)
  end

  # Move table to another schema
  # @param [String] table table name. Can be with schema prefix e.g. "demography.people"
  # @param [String] schema schema where table should be moved to.
  def move_table_to_schema(table, schema)
    ::PgPower::Tools.move_table_to_schema(table, schema)
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
  def tables_with_non_public_schema_tables(*args)
    public_tables = tables_without_non_public_schema_tables(*args)

    non_public_tables =
      query(<<-SQL, 'SCHEMA').map { |row| row[0] }
        SELECT schemaname || '.' || tablename AS table
        FROM pg_tables
        WHERE schemaname NOT IN ('pg_catalog', 'information_schema', 'public')
      SQL

    public_tables + non_public_tables
  end
end
