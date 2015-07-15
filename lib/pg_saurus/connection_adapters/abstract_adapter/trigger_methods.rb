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
  #   create_trigger :pets,                           # Table or view name
  #                  :pets_not_empty_trigger_proc,    # Procedure name. Parentheses are optional if you have no arguments.
  #                  'AFTER INSERT',                  # Trigger event
  #                  for_each: 'ROW',                 # Can be row or statement. Default is row.
  #                  schema: 'public',                # Optional schema name
  #                  constraint: true,                # Sets if the trigger is a constraint. Default is false.
  #                  deferrable: true,                # Sets if the trigger is immediate or deferrable. Default is immediate.
  #                  initially_deferred: true,        # Sets if the trigger is initially deferred. Default is immediate. Only relevant if the trigger is deferrable.
  #                  condition: "new.name = 'fluffy'" # Optional when condition. Default is none.
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
