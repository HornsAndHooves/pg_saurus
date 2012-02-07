module PgPower
  module ConnectionAdapters
    module PostgreSQLAdapter
      extend ActiveSupport::Autoload

      autoload :SchemaMethods,  'pg_power/connection_adapters/postgresql_adapter/schema_methods'
      autoload :CommentMethods, 'pg_power/connection_adapters/postgresql_adapter/comment_methods'

      include SchemaMethods
      include CommentMethods
    end
  end
end
