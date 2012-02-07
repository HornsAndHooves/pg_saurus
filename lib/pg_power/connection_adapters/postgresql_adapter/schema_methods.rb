module PgPower::ConnectionAdapters::PostgreSQLAdapter::SchemaMethods
  def create_schema(schema_name)
    ::PgPower::Tools.create_schema(schema_name)
  end

  def drop_schema(schema_name)
    ::PgPower::Tools.drop_schema(schema_name)
  end
end
