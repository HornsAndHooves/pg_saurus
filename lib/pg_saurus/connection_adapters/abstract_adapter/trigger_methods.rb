# Adapter definitions for db functions
module PgSaurus::ConnectionAdapters::AbstractAdapter::TriggerMethods

  # :nodoc
  def supports_triggers?
    false
  end

  # Returns the listing of currently defined db triggers
  def triggers

  end

  # Creates a trigger.
  #
  # Example:
  #
  #   create_trigger :pets,
  #                  :pets_not_empty_trigger_proc,
  #                  'AFTER INSERT',
  #                  for_each: 'ROW',
  #                  schema: 'public',
  #                  constraint: true,
  #                  deferrable: true,
  #                  initially_deferred: true
  #
  def create_trigger(table_name, proc_name, event, options = {})

  end

  # Removes a trigger.
  #
  # Example:
  #
  #   remove_trigger :pets, :pets_not_empty_trigger_proc
  #
  def remove_trigger(table_name, proc_name, options = {})

  end

end
