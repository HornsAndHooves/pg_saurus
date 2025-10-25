# Extends ActiveRecord::ConnectionAdapters::AbstractAdapter class.
module PgSaurus::ConnectionAdapters::AbstractAdapter
  extend ActiveSupport::Autoload

  autoload :SchemaMethods
  autoload :IndexMethods
  autoload :FunctionMethods
  autoload :TriggerMethods

  include SchemaMethods
  include IndexMethods
  include FunctionMethods
  include TriggerMethods
end
