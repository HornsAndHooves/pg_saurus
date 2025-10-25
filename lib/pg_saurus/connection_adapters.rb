module PgSaurus::ConnectionAdapters # :nodoc:
  extend ActiveSupport::Autoload

  autoload :PostgreSQLAdapter,  'pg_saurus/connection_adapters/postgresql_adapter'
  autoload :Table
  autoload :FunctionDefinition, 'pg_saurus/connection_adapters/function_definition'
  autoload :TriggerDefinition,  'pg_saurus/connection_adapters/trigger_definition'
end
