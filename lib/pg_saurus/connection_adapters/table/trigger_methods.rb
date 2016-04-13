# Provides methods to extend ActiveRecord::ConnectionAdapters::Table
# to support database triggers.
module PgSaurus::ConnectionAdapters::Table::TriggerMethods

  # Creates a trigger.
  #
  # Example:
  #
  #   change_table :pets do |t|
  #     t.create_trigger :pets_not_empty_trigger_proc,
  #                      'AFTER INSERT',
  #                      for_each: 'ROW',
  #                      schema: 'public',
  #                      constraint: true,
  #                      deferrable: true,
  #                      initially_deferred: true
  #   end
  def create_trigger(proc_name, event, options = {})
    @base.create_trigger(@name, proc_name, event, options)
  end

  # Removes a trigger.
  #
  # Example:
  #
  #   change_table :pets do |t|
  #     t.remove_trigger :pets_not_empty_trigger_proc
  #   end
  def remove_trigger(proc_name, options = {})
    @base.remove_trigger(@name, proc_name, options)
  end

end
