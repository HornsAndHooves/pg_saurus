# Provides methods to extend {ActiveRecord::Migration::CommandRecorder} to
# support foreign keys feature.
module PgPower::Migration::CommandRecorder::ForeignerMethods
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

    if add_options[:name]
      options = {:name => add_options[:name]}
    elsif add_options[:column]
      options = {:column => add_options[:column]}
    else
      options = to_table
    end

    [:remove_foreign_key, [from_table, options]]
  end
end
