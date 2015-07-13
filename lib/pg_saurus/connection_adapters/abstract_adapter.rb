# Extends ActiveRecord::ConnectionAdapters::AbstractAdapter class.
module PgSaurus::ConnectionAdapters::AbstractAdapter
  extend ActiveSupport::Autoload
  extend ActiveSupport::Concern

  autoload :CommentMethods
  autoload :ForeignerMethods
  autoload :SchemaMethods
  autoload :IndexMethods
  autoload :FunctionMethods

  include CommentMethods
  include ForeignerMethods
  include SchemaMethods
  include IndexMethods
  include FunctionMethods

  included do
    alias_method_chain :create_table, :schema_option
    alias_method_chain :drop_table  , :schema_option
  end
end
