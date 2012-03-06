# Extends {ActiveRecord::ConnectionAdapters::AbstractAdapter} class.
module PgPower::ConnectionAdapters::AbstractAdapter
  extend ActiveSupport::Autoload
  extend ActiveSupport::Concern

  autoload :CommentMethods
  autoload :ForeignerMethods
  autoload :SchemaMethods
  autoload :IndexMethods

  include CommentMethods
  include ForeignerMethods
  include SchemaMethods
  include IndexMethods

  included do
    alias_method_chain :create_table, :schema_option
    alias_method_chain :drop_table  , :schema_option
  end
end
