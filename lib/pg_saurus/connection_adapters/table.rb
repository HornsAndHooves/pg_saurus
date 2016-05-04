# Provides methods to extend ActiveRecord::ConnectionAdapters::Table
# to support pg_saurus features.
module PgSaurus::ConnectionAdapters::Table
  extend ActiveSupport::Autoload

  autoload :CommentMethods
  autoload :TriggerMethods

  include CommentMethods
  include TriggerMethods

end
