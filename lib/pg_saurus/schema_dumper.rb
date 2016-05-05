# Provides methods to extend {ActiveRecord::SchemaDumper} to appropriately
# build schema.rb file with schemas, foreign keys and comments on columns
# and tables.
module PgSaurus::SchemaDumper
  extend ActiveSupport::Autoload
  extend ActiveSupport::Concern

  autoload :ExtensionMethods
  autoload :CommentMethods
  autoload :SchemaMethods
  autoload :ForeignKeyMethods
  autoload :ViewMethods
  autoload :FunctionMethods
  autoload :TriggerMethods

  include ExtensionMethods
  include CommentMethods
  include SchemaMethods
  include ForeignKeyMethods
  include ViewMethods
  include FunctionMethods
  include TriggerMethods

  included do
    alias_method_chain :header, :schemas
    alias_method_chain :header, :extensions

    alias_method_chain :tables, :views
    alias_method_chain :tables, :functions
    alias_method_chain :tables, :triggers
    alias_method_chain :tables, :comments

    alias_method_chain :foreign_keys, :indexes
  end
end
