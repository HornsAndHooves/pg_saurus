# Provides methods to extend {ActiveRecord::SchemaDumper} to appropriately
# build schema.rb file with schemas, foreign keys and comments on columns
# and tables.
module PgSaurus::SchemaDumper
  extend ActiveSupport::Autoload

  autoload :SchemaMethods
  autoload :ForeignKeyMethods
  autoload :ViewMethods
  autoload :FunctionMethods
  autoload :TriggerMethods

  include SchemaMethods
  include ForeignKeyMethods
  include ViewMethods
  include FunctionMethods
  include TriggerMethods
end
