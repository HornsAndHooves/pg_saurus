# Methods to extend ActiveRecord::Migration::CommandRecorder to
# support database triggers.
module PgSaurus::Migration::CommandRecorder::TriggerMethods

  # :nodoc:
  def create_trigger(*args)
    record :create_trigger, args
  end

  # :nodoc:
  def remove_trigger(*args)
    record :remove_trigger, args
  end

  # :nodoc:
  def invert_create_trigger(args)
    table_name, proc_name, _, options = *args
    options ||= {}

    [:remove_trigger, [table_name, proc_name, options]]
  end

end
