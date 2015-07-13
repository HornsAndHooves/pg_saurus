# Adapter definitions for db functions
module PgSaurus::ConnectionAdapters::AbstractAdapter::FunctionMethods

  # :nodoc
  def supports_functions?
    false
  end

  # Creates a database function
  def create_function(function_name, returning, definition, options = {})

  end

  # Deletes the database function
  def drop_function(function_name, options)

  end

  # Returns the listing of currently defined db functions
  def functions

  end

end
