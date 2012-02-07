# Provides methods to fetch comment messages on tables and columns
module PgCommentGetter
  extend self

  def get_table_comment(table_name)
    schema, table = to_schema_and_table(table_name)

    connection.query(<<-SQL).flatten.first
      SELECT pg_desc.description
      FROM pg_catalog.pg_description pg_desc
        INNER JOIN pg_catalog.pg_class pg_class ON pg_class.oid = pg_desc.objoid
        INNER JOIN pg_namespace ON pg_class.relnamespace = pg_namespace.oid
      WHERE pg_class.relname = '#{table}' AND
        pg_namespace.nspname = '#{schema}' AND
	pg_desc.objsubid = 0  --means table
    SQL
  end

  def get_column_comment(table_name, column)
    schema, table = to_schema_and_table(table_name)

    connection.query(<<-SQL).flatten.first
      SELECT d.description
      FROM pg_description d
        JOIN pg_class c on c.oid = d.objoid
        JOIN pg_attribute a ON c.oid = a.attrelid AND a.attnum = d.objsubid
        JOIN pg_namespace ON c.relnamespace = pg_namespace.oid
      WHERE c.relkind = 'r' AND
        c.relname = '#{table}' AND
        pg_namespace.nspname = '#{schema}' AND
        a.attname = '#{column}'
    SQL
  end


  private

  def to_schema_and_table(table_name)
    table, schema = table_name.split(".", 2).reverse
    schema ||= "public" 
    [schema, table]
  end

  def connection
    ActiveRecord::Base.connection
  end
end
