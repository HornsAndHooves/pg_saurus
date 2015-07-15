# Adapter definitions for DB functions.
module PgSaurus::ConnectionAdapters::AbstractAdapter::FunctionMethods

  # :nodoc
  def supports_functions?
    false
  end

  # Create a database function.
  #
  # Example:
  #
  #   # Arguments are: function_name, return_type, function_definition, options (currently, only :schema)
  #   create_function 'pets_not_empty()', :boolean, <<-FUNCTION, schema: 'public'
  #     BEGIN
  #       IF (SELECT COUNT(*) FROM pets) > 0
  #       THEN
  #       RETURN true;
  #       ELSE
  #       RETURN false;
  #      END IF;
  #       END;
  #     FUNCTION
  #
  # The schema is optional.
  def create_function(function_name, returning, definition, options = {})

  end

  # Delete the database function.
  #
  # Example:
  #
  #   drop_function 'pets_not_empty()', schema: 'public'
  #
  # The schema is optional.
  def drop_function(function_name, options)

  end

  # Return the listing of currently defined DB functions.
  def functions

  end

end
