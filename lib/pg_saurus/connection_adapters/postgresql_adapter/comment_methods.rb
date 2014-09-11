# Provides methods to extend {ActiveRecord::ConnectionAdapters::PostgreSQLAdapter}
# to support comments feature.
module PgSaurus::ConnectionAdapters::PostgreSQLAdapter::CommentMethods
  def supports_comments?
    true
  end

  # Executes SQL to set comment on table
  # @param [String, Symbol] table_name name of table to set a comment on
  # @param [String] comment
  def set_table_comment(table_name, comment)
    sql = "COMMENT ON TABLE #{quote_table_name(table_name)} IS $$#{comment}$$;"
    execute sql
  end

  # Executes SQL to set comment on column.
  # @param [String, Symbol] table_name
  # @param [String, Symbol] column_name
  # @param [String] comment
  def set_column_comment(table_name, column_name, comment)
    sql = "COMMENT ON COLUMN #{quote_table_name(table_name)}.#{quote_column_name(column_name)} IS $$#{comment}$$;"
    execute sql
  end

  # Sets comments on columns of passed table.
  # @param [String, Symbol] table_name
  # @param [Hash] comments every key is a column name and value is a comment.
  def set_column_comments(table_name, comments)
    comments.each_pair do |column_name, comment|
      set_column_comment table_name, column_name, comment
    end
  end

  # Sets the given comment on the given index
  # @param [String, Symbol] index_name The name of the index
  # @param [String, Symbol] comment The comment to set on the index
  def set_index_comment(index_name, comment)
    sql = "COMMENT ON INDEX #{quote_string(index_name)} IS $$#{comment}$$;"
    execute sql
  end

  # Executes SQL to remove comment on passed table.
  # @param [String, Symbol] table_name
  def remove_table_comment(table_name)
    sql = "COMMENT ON TABLE #{quote_table_name(table_name)} IS NULL;"
    execute sql
  end

  # Executes SQL to remove comment on column.
  # @param [String, Symbol] table_name
  # @param [String, Symbol] column_name
  def remove_column_comment(table_name, column_name)
    sql = "COMMENT ON COLUMN #{quote_table_name(table_name)}.#{quote_column_name(column_name)} IS NULL;"
    execute sql
  end

  # Remove comments on passed table columns.
  def remove_column_comments(table_name, *column_names)
    column_names.each do |column_name|
      remove_column_comment table_name, column_name
    end
  end

  # Removes any comment from the given index
  # @param [String, Symbol] index_name The name of the index
  def remove_index_comment(index_name)
    sql = "COMMENT ON INDEX #{quote_string(index_name)} IS NULL;"
    execute sql
  end

  # Fetches all comments related to passed table.
  # I returns table comment and column comments as well.
  # ===Example
  #   comments("users") # => [[ ""    , "Comment on table"       ],
  #                           ["id"   , "Comment on id column"   ],
  #                           ["email", "Comment on email column"]]
  def comments(table_name)
    relation_name, schema_name = table_name.split(".", 2).reverse
    schema_name ||= :public

    com = select_all <<-SQL
      SELECT a.attname AS column_name, d.description AS comment
      FROM pg_description d
        JOIN pg_class c on c.oid = d.objoid
        LEFT OUTER JOIN pg_attribute a ON c.oid = a.attrelid AND a.attnum = d.objsubid
        JOIN pg_namespace ON c.relnamespace = pg_namespace.oid
      WHERE c.relkind = 'r' AND c.relname = '#{relation_name}' AND
        pg_namespace.nspname = '#{schema_name}'
    SQL
    com.map do |row|
      [ row['column_name'], row['comment'] ]
    end
  end

  # Fetches index comments
  # returns an Array of Arrays, each element representing a single index with comment as
  #  [ 'schema_name', 'index_name', 'comment' ]
  def index_comments
    query =  <<-SQL
      SELECT c.relname AS index_name, d.description AS comment, pg_namespace.nspname AS schema_name
      FROM pg_description d
      JOIN pg_class c ON c.oid = d.objoid
      JOIN pg_namespace ON c.relnamespace = pg_namespace.oid
      WHERE c.relkind = 'i'
      ORDER BY schema_name, index_name
    SQL

    com = select_all(query)

    com.map do |row|
      [ row['schema_name'], row['index_name'], row['comment'] ]
    end
  end
end
