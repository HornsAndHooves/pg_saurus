# Extends {ActiveRecord::ConnectionAdapters::AbstractAdapter} class.
module PgPower::ConnectionAdapters::AbstractAdapter
  extend ActiveSupport::Autoload

  autoload :CommentMethods
  autoload :ForeignerMethods
  autoload :IndexMethods

  include CommentMethods
  include ForeignerMethods
  include IndexMethods
end
