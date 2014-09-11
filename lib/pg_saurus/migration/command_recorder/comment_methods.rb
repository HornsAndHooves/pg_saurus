# Provides methods to extend ActiveRecord::Migration::CommandRecorder to
# support comments feature.
module  PgSaurus::Migration::CommandRecorder::CommentMethods
  # :nodoc:
  def set_table_comment(*args)
    record(:set_table_comment, args)
  end

  # :nodoc:
  def remove_table_comment(*args)
    record(:remove_table_comment, args)
  end

  # :nodoc:
  def set_column_comment(*args)
    record(:set_column_comment, args)
  end

  # :nodoc:
  def set_column_comments(*args)
    record(:set_column_comments, args)
  end

  # :nodoc:
  def remove_column_comment(*args)
    record(:remove_column_comment, args)
  end

  # :nodoc:
  def remove_column_comments(*args)
    record(:remove_column_comments, args)
  end

  # :nodoc:
  def set_index_comment(*args)
    record(:set_index_comment, args)
  end

  # :nodoc:
  def remove_index_comment(*args)
    record(:remove_index_comment, args)
  end

  # :nodoc:
  def invert_set_table_comment(args)
    table_name = args.first
    [:remove_table_comment, [table_name]]
  end

  # :nodoc:
  def invert_set_column_comment(args)
    table_name = args[0]
    column_name = args[1]
    [:remove_column_comment, [table_name, column_name]]
  end

  # :nodoc:
  def invert_set_column_comments(args)
    i_args = [args[0]] + args[1].collect{|name, value| name  }
    [:remove_column_comments, i_args]
  end

  # :nodoc:
  def invert_set_index_comment(args)
    index_name = args.first
    [:remove_index_comment, [index_name]]
  end
end
