module PgComment
  module SchemaDumper
    extend ActiveSupport::Concern

    included do
      alias_method_chain :tables, :comments
    end

    def tables_with_comments(stream)
      tables_without_comments(stream)
      @connection.tables.sort.each do |table_name|
        dump_comments(table_name, stream)
      end
    end

    def dump_comments(table_name, stream)
      unless (comments = @connection.comments(table_name)).empty?
        comment_statements = comments.map do |row|
          column_name = row[0]
          comment = row[1]
          
          if column_name
            "  set_column_comment '#{table_name}', '#{column_name}', '#{comment.gsub(/'/, "\\\\'")}'"
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
end