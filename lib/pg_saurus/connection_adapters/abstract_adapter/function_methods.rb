# Adapter definitions for DB functions.
module PgSaurus::ConnectionAdapters::AbstractAdapter::FunctionMethods

  # :nodoc
  def supports_functions?
    false
  end

  # Create a database function.
  def create_function(function_name, returning, definition, options = {})

  end

  # Delete the database function.
  def drop_function(function_name, options)

  end

  # Return the listing of currently defined DB functions.
  def functions

  end

end
