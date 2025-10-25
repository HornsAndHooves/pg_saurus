# Provides methods to extend {ActiveRecord::ConnectionAdapters::PostgreSQLAdapter}
# to support pg_saurus features.
module PgSaurus::ConnectionAdapters::PostgreSQLAdapter
  extend ActiveSupport::Autoload
  extend ActiveSupport::Concern

  # TODO: Looks like explicit path specification can be omitted -- aignatyev 20120904
  autoload :SchemaMethods,      'pg_saurus/connection_adapters/postgresql_adapter/schema_methods'
  autoload :ForeignKeyMethods,  'pg_saurus/connection_adapters/postgresql_adapter/foreign_key_methods'
  autoload :IndexMethods,       'pg_saurus/connection_adapters/postgresql_adapter/index_methods'
  autoload :TranslateException, 'pg_saurus/connection_adapters/postgresql_adapter/translate_exception'
  autoload :ViewMethods,        'pg_saurus/connection_adapters/postgresql_adapter/view_methods'
  autoload :FunctionMethods,    'pg_saurus/connection_adapters/postgresql_adapter/function_methods'
  autoload :TriggerMethods,     'pg_saurus/connection_adapters/postgresql_adapter/trigger_methods'

  include SchemaMethods
  include ForeignKeyMethods
  include IndexMethods
  include TranslateException
  include ViewMethods
  include FunctionMethods
  include TriggerMethods

  included do
    ::ActiveRecord::ConnectionAdapters::ForeignKeyDefinition.module_eval do
      def from_schema
        options[:from_schema] || 'public'
      end
    end
  end
end
