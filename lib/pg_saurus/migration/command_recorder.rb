# Provides methods to extend ActiveRecord::Migration::CommandRecorder to
# support pg_saurus features.
module PgSaurus::Migration::CommandRecorder
  extend ActiveSupport::Autoload

  autoload :ExtensionMethods
  autoload :SchemaMethods
  autoload :CommentMethods
  #autoload :ForeignKeyMethods
  autoload :ViewMethods
  autoload :FunctionMethods
  autoload :TriggerMethods

  include ExtensionMethods
  include SchemaMethods
  include CommentMethods
  #include ForeignerMethods
  include ViewMethods
  include FunctionMethods
  include TriggerMethods
end
