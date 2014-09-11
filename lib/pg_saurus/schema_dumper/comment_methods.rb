# Extends ActiveRecord::SchemaDumper class to dump comments on tables and columns.
module PgSaurus::SchemaDumper::CommentMethods
  # Hook ActiveRecord::SchemaDumper#table method to dump comments on
  # table and columns.
  def tables_with_comments(stream)
    tables_without_comments(stream)

    # Dump table and column comments
    @connection.tables.sort.each do |table_name|
      dump_comments(table_name, stream)
    end

    # Now dump index comments
    unless (index_comments = @connection.index_comments).empty?
      index_comments.each do |schema_name, table_name, raw_comment|
        index_name = schema_name == 'public' ? "'#{table_name}'" : "'#{schema_name}.#{table_name}'"
        comment    = format_comment(raw_comment)
        stream.puts "  set_index_comment #{index_name}, '#{comment}'"
      end
      stream.puts
    end
  end

  # Find all comments related to passed table and write appropriate
  # statements to stream.
  def dump_comments(table_name, stream)
    unless (comments = @connection.comments(table_name)).empty?
      comment_statements = comments.map do |row|
        column_name = row[0]
        comment     = format_comment(row[1])

        if column_name
          "  set_column_comment '#{table_name}', '#{column_name}', '#{comment}'"
        else
          "  set_table_comment '#{table_name}', '#{comment}'"
        end

      end

      stream.puts comment_statements.join("\n")
      stream.puts
    end
  end
  private :dump_comments

  # Escape single quotes from comments.
  def format_comment(comment)
    comment.gsub(/'/, "\\\\'")
  end
  private :format_comment
end
