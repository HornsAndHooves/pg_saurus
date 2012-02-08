# Extends {ActiveRecord::ConnectionAdapters::AbstractAdapter} class.
module PgPower::ConnectionAdapters::AbstractAdapter
  extend ActiveSupport::Autoload

  autoload :CommentMethods
  autoload :ForeignerMethods

  include CommentMethods
  include ForeignerMethods
end
