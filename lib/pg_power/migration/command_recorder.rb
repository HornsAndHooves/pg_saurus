# Provides methods to extend {ActiveRecord::Migration::CommandRecorder} to 
# support pg_power features.
module PgPower::Migration::CommandRecorder
  extend ActiveSupport::Autoload

  autoload :SchemaMethods
  autoload :CommentMethods
  autoload :ForeignerMethods

  include SchemaMethods
  include CommentMethods
  include ForeignerMethods
end
