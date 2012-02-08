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
end
