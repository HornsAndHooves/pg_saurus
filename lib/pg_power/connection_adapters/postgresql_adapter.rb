module PgPower
  module ConnectionAdapters
    module PostgreSQLAdapter
      extend ActiveSupport::Autoload
      extend ActiveSupport::Concern

      autoload :SchemaMethods   , 'pg_power/connection_adapters/postgresql_adapter/schema_methods'
      autoload :CommentMethods  , 'pg_power/connection_adapters/postgresql_adapter/comment_methods'
      autoload :ForeignerMethods, 'pg_power/connection_adapters/postgresql_adapter/foreigner_methods'

      include SchemaMethods
      include CommentMethods
      include ForeignerMethods
    end
  end
end
