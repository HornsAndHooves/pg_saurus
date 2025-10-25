module PgSaurus::ConnectionAdapters # :nodoc:
  extend ActiveSupport::Autoload

  autoload :PostgreSQLAdapter,  'pg_saurus/connection_adapters/postgresql_adapter'
  autoload :TriggerDefinition,  'pg_saurus/connection_adapters/trigger_definition'
end
