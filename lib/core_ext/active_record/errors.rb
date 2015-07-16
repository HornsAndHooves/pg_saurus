module ActiveRecord
  # Raised when an DB operation cannot be carried out because the current
  # database user lacks the required privileges.
  class InsufficientPrivilege < WrappedDatabaseException
  end
end
