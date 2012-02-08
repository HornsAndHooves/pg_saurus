module PgPower::ConnectionAdapters
  extend ActiveSupport::Autoload

  autoload :AbstractAdapter
  autoload :PostgreSQLAdapter, 'pg_power/connection_adapters/postgresql_adapter'
  autoload :Table
  autoload :ForeignKeyDefinition

  autoload_under 'abstract' do
    autoload :SchemaDefinitions
    autoload :SchemaStatements
  end
end
