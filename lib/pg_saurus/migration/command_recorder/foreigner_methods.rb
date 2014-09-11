# Provides methods to extend ActiveRecord::Migration::CommandRecorder to
# support foreign keys feature.
module PgSaurus::Migration::CommandRecorder::ForeignerMethods
  # :nodoc:
  def add_foreign_key(*args)
    record(:add_foreign_key, args)
  end

  # :nodoc:
  def remove_foreign_key(*args)
    record(:remove_foreign_key, args)
  end

  # :nodoc:
  def invert_add_foreign_key(args)
    from_table, to_table, add_options = *args
    add_options ||= {}
    add_name_option   = add_options[:name]
    add_column_option = add_options[:column]

    if add_name_option then
      options = {:name => add_name_option}
    elsif add_column_option
      options = {:column => add_column_option}
    else
      options = to_table
    end

    [:remove_foreign_key, [from_table, options]]
  end
end
