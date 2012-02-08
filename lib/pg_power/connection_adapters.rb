module PgPower::ConnectionAdapters # :nodoc:
  extend ActiveSupport::Autoload

  autoload :AbstractAdapter
  autoload :PostgreSQLAdapter, 'pg_power/connection_adapters/postgresql_adapter'
  autoload :Table
  autoload :ForeignKeyDefinition
end
