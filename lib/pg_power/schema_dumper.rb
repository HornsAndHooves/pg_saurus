# Provides methods to extend {ActiveRecord::SchemaDumper} to appropriately
# build schema.rb file with schemas, foreign keys and comments on columns
# and tables.
module PgPower::SchemaDumper
  extend ActiveSupport::Autoload
  extend ActiveSupport::Concern

  autoload :CommentMethods
  autoload :SchemaMethods
  autoload :ForeignerMethods

  include CommentMethods
  include SchemaMethods
  include ForeignerMethods

  included do
    alias_method_chain :tables, :schemas
    alias_method_chain :tables, :comments
    alias_method_chain :tables, :foreign_keys
  end
end
