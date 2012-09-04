module ActiveRecord
  # Raised when a record cannot be accessed because current database user has no needed privileges
  class InsufficientPrivilege < WrappedDatabaseException
  end
end