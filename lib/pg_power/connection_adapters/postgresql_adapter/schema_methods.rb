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
end
