# Adapter definitions for db functions
module PgSaurus::ConnectionAdapters::AbstractAdapter::TriggerMethods

  # :nodoc
  def supports_triggers?
    false
  end

  # Returns the listing of currently defined db triggers
  def triggers

  end

  def create_trigger(table_name, proc_name, event, options = {})

  end

  def remove_trigger(table_name, proc_name, options = {})

  end

end
