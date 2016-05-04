# Provides methods to extend ActiveRecord::ConnectionAdapters::Table
# to support comments feature.
module PgSaurus::ConnectionAdapters::Table::CommentMethods
  # Set the comment on the table.
  #
  # ===== Example
  # ====== Set comment on table
  #   t.set_table_comment 'This table stores phone numbers that conform to the North American Numbering Plan.'
  def set_table_comment(comment)
    @base.set_table_comment(@name, comment)
  end

  # Remove any comment from the table.
  #
  # ===== Example
  # ====== Remove table comment
  #   t.remove_table_comment
  def remove_table_comment
    @base.remove_table_comment(@name)
  end

  # Set the comment for a given column.
  #
  # ===== Example
  # ====== Set comment on the npa column
  #   t.set_column_comment :npa, 'Numbering Plan Area Code - Allowed ranges: [2-9] for first digit, [0-9] for second and third digit.'
  def set_column_comment(column_name, comment)
    @base.set_column_comment(@name, column_name, comment)
  end

  # Set comments on multiple columns. 'comments' is a hash of column_name => comment pairs.
  #
  # ===== Example
  # ====== Setting comments on the columns of the phone_numbers table
  #  t.set_column_comments :npa => 'Numbering Plan Area Code - Allowed ranges: [2-9] for first digit, [0-9] for second and third digit.',
  #                        :nxx => 'Central Office Number'
  def set_column_comments(comments)
    @base.set_column_comments(@name, comments)
  end

  # Remove any comment for a given column.
  #
  # ===== Example
  # ====== Remove comment from the npa column
  #   t.remove_column_comment :npa
  def remove_column_comment(column_name)
    @base.remove_column_comment(@name, column_name)
  end

  # Remove any comments from the given columns.
  #
  # ===== Example
  # ====== Remove comment from the npa and nxx columns
  #   t.remove_column_comment :npa, :nxx
  def remove_column_comments(*column_names)
    @base.remove_column_comments(@name, *column_names)
  end
end
