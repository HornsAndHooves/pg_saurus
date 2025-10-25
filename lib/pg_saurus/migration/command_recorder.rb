# Provides methods to extend ActiveRecord::Migration::CommandRecorder to
# support pg_saurus features.
module PgSaurus::Migration::CommandRecorder
  extend ActiveSupport::Autoload

  autoload :ViewMethods
  autoload :FunctionMethods
  autoload :TriggerMethods

  include ViewMethods
  include FunctionMethods
  include TriggerMethods
end
