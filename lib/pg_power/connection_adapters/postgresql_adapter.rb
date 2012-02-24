# Provides methods to extend {ActiveRecord::ConnectionAdapters::PostgreSQLAdapter}
# to support pg_power features.
module PgPower::ConnectionAdapters::PostgreSQLAdapter
  extend ActiveSupport::Autoload
  extend ActiveSupport::Concern

  autoload :SchemaMethods   , 'pg_power/connection_adapters/postgresql_adapter/schema_methods'
  autoload :CommentMethods  , 'pg_power/connection_adapters/postgresql_adapter/comment_methods'
  autoload :ForeignerMethods, 'pg_power/connection_adapters/postgresql_adapter/foreigner_methods'
  autoload :IndexMethods,     'pg_power/connection_adapters/postgresql_adapter/index_methods'

  include SchemaMethods
  include CommentMethods
  include ForeignerMethods
  include IndexMethods
end
