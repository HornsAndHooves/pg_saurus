module PgSaurus::ConnectionAdapters # :nodoc:
  extend ActiveSupport::Autoload

  autoload :AbstractAdapter
  autoload :PostgreSQLAdapter, 'pg_saurus/connection_adapters/postgresql_adapter'
  autoload :Table
  autoload :ForeignKeyDefinition
  autoload :IndexDefinition, 'pg_saurus/connection_adapters/index_definition'
end
