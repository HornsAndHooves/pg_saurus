# Extends ActiveRecord::SchemaDumper class to dump comments on tables and columns
module PgPower::SchemaDumper::CommentMethods
  def tables_with_comments(stream)
    tables_without_comments(stream)

    table_names = @connection.tables.sort
    table_names += get_non_public_schema_table_names.sort

    table_names.each do |table_name|
      dump_comments(table_name, stream)
    end
  end

  def dump_comments(table_name, stream)
    unless (comments = @connection.comments(table_name)).empty?
      comment_statements = comments.map do |row|
        column_name = row[0]
        comment = row[1].gsub(/'/, "\\\\'")
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
end