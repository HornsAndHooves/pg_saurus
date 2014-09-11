# Provides methods to extend ActiveRecord::ConnectionAdapters::Table
# to support pg_saurus features.
module PgSaurus::ConnectionAdapters::Table
  extend ActiveSupport::Autoload
  extend ActiveSupport::Concern

  autoload :CommentMethods
  autoload :ForeignerMethods

  include CommentMethods
  include ForeignerMethods


  included do
    alias_method_chain :references, :foreign_keys
  end
end
