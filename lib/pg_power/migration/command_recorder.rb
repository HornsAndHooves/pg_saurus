# Provides methods to extend {ActiveRecord::Migration::CommandRecorder} to 
# support pg_power features.
module PgPower::Migration::CommandRecorder
  extend ActiveSupport::Autoload

  autoload :ExtensionMethods
  autoload :SchemaMethods
  autoload :CommentMethods
  autoload :ForeignerMethods
  autoload :ViewMethods

  include ExtensionMethods
  include SchemaMethods
  include CommentMethods
  include ForeignerMethods
  include ViewMethods
end
