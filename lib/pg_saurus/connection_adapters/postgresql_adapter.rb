# Provides methods to extend {ActiveRecord::ConnectionAdapters::PostgreSQLAdapter}
# to support pg_saurus features.
module PgSaurus::ConnectionAdapters::PostgreSQLAdapter
  extend ActiveSupport::Autoload
  extend ActiveSupport::Concern

  # TODO: Looks like explicit path specification can be omitted -- aignatyev 20120904
  autoload :ExtensionMethods,   'pg_saurus/connection_adapters/postgresql_adapter/extension_methods'
  autoload :SchemaMethods,      'pg_saurus/connection_adapters/postgresql_adapter/schema_methods'
  autoload :CommentMethods,     'pg_saurus/connection_adapters/postgresql_adapter/comment_methods'
  autoload :ForeignerMethods,   'pg_saurus/connection_adapters/postgresql_adapter/foreigner_methods'
  autoload :IndexMethods,       'pg_saurus/connection_adapters/postgresql_adapter/index_methods'
  autoload :TranslateException, 'pg_saurus/connection_adapters/postgresql_adapter/translate_exception'
  autoload :ViewMethods,        'pg_saurus/connection_adapters/postgresql_adapter/view_methods'
  autoload :FunctionMethods,    'pg_saurus/connection_adapters/postgresql_adapter/function_methods'

  include ExtensionMethods
  include SchemaMethods
  include CommentMethods
  include ForeignerMethods
  include IndexMethods
  include TranslateException
  include ViewMethods
  include FunctionMethods

  included do
    alias_method_chain :tables, :non_public_schema_tables
    alias_method_chain :add_index, :concurrently
  end
end
