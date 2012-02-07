module PgPower::Migration::CommandRecorder
  extend ActiveSupport::Autoload

  autoload :SchemaMethods
  autoload :CommentMethods

  include SchemaMethods
  include CommentMethods
end
