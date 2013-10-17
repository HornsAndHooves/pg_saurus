# Provides methods to extend {ActiveRecord::ConnectionAdapters::PostgreSQLAdapter}
# to support pg_power features.
module PgPower::ConnectionAdapters::PostgreSQLAdapter
  extend ActiveSupport::Autoload
  extend ActiveSupport::Concern

  # TODO: Looks like explicit path specification can be omitted -- aignatyev 20120904
  autoload :ExtensionMethods,      'pg_power/connection_adapters/postgresql_adapter/extension_methods'
  autoload :SchemaMethods,      'pg_power/connection_adapters/postgresql_adapter/schema_methods'
  autoload :CommentMethods,     'pg_power/connection_adapters/postgresql_adapter/comment_methods'
  autoload :ForeignerMethods,   'pg_power/connection_adapters/postgresql_adapter/foreigner_methods'
  autoload :IndexMethods,       'pg_power/connection_adapters/postgresql_adapter/index_methods'
  autoload :TranslateException, 'pg_power/connection_adapters/postgresql_adapter/translate_exception'
  autoload :ViewMethods,        'pg_power/connection_adapters/postgresql_adapter/view_methods'

  include ExtensionMethods
  include SchemaMethods
  include CommentMethods
  include ForeignerMethods
  include IndexMethods
  include TranslateException
  include ViewMethods
end
