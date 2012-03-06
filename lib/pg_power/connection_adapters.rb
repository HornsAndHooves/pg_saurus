module PgPower::ConnectionAdapters # :nodoc:
  extend ActiveSupport::Autoload

  autoload :AbstractAdapter
  autoload :PostgreSQLAdapter, 'pg_power/connection_adapters/postgresql_adapter'
  autoload :Table
  autoload :ForeignKeyDefinition
  autoload :IndexDefinition, 'pg_power/connection_adapters/index_definition'
end
