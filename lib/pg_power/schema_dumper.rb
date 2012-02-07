module PgPower::SchemaDumper
  extend ActiveSupport::Autoload
  extend ActiveSupport::Concern

  autoload :CommentMethods
  autoload :SchemaMethods

  include CommentMethods
  include SchemaMethods

  included do
    alias_method_chain :tables, :schemas
    alias_method_chain :tables, :comments
  end
end
