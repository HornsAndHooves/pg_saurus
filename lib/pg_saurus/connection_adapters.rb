module PgSaurus::ConnectionAdapters # :nodoc:
  extend ActiveSupport::Autoload

  autoload :AbstractAdapter
  autoload :PostgreSQLAdapter,  'pg_saurus/connection_adapters/postgresql_adapter'
  autoload :Table
  autoload :IndexDefinition,    'pg_saurus/connection_adapters/index_definition'
  autoload :FunctionDefinition, 'pg_saurus/connection_adapters/function_definition'
  autoload :TriggerDefinition,  'pg_saurus/connection_adapters/trigger_definition'
end
