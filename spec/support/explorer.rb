# Provides methods to fetch meta information about DB like comments and
# foreign keys. It's used in test purpose.
module PgSaurus::Explorer
  extend self

  def get_table_comment(table_name)
    schema, table = to_schema_and_table(table_name)

    connection.query(<<-SQL).flatten.first
      SELECT pg_desc.description
      FROM pg_catalog.pg_description pg_desc
        INNER JOIN pg_catalog.pg_class pg_class ON pg_class.oid = pg_desc.objoid
        INNER JOIN pg_namespace ON pg_class.relnamespace = pg_namespace.oid
      WHERE pg_class.relname = '#{table}'
        AND pg_namespace.nspname = '#{schema}'
        AND pg_desc.objsubid = 0  -- means table
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
      WHERE c.relkind = 'r'
        AND c.relname = '#{table}'
        AND pg_namespace.nspname = '#{schema}'
        AND a.attname = '#{column}'
    SQL
  end

  def get_index_comment(index_name)
    schema, index = to_schema_and_table(index_name)
    connection.query(<<-SQL).flatten.first
      SELECT d.description AS comment
      FROM pg_description d
      JOIN pg_class c ON c.oid = d.objoid
      JOIN pg_namespace ON c.relnamespace = pg_namespace.oid
      WHERE c.relkind = 'i'
        AND c.relname = '#{index}'
        AND pg_namespace.nspname = '#{schema}'
    SQL
  end

  def has_foreign_key?(table_name, column)
    schema, table = to_schema_and_table(table_name)

    !!connection.query(<<-SQL).flatten.first
      SELECT tc.constraint_name
      FROM information_schema.table_constraints AS tc
        JOIN information_schema.key_column_usage AS kcu ON tc.constraint_name = kcu.constraint_name
        JOIN information_schema.constraint_column_usage AS ccu ON ccu.constraint_name = tc.constraint_name
      WHERE constraint_type = 'FOREIGN KEY'
        AND tc.table_name='#{table}'
        AND tc.table_schema = '#{schema}'
        AND kcu.column_name = '#{column}'
    SQL
  end

  def index_exists?(table_name, column_name, options = {})
    connection.index_exists?(table_name.to_s, column_name, options)
  end

  def table_exists?(table_name)
    schema, table = to_schema_and_table(table_name)
    !!connection.query(<<-SQL).flatten.first
      SELECT *
      FROM pg_class
        INNER JOIN pg_namespace ON pg_class.relnamespace = pg_namespace.oid
      WHERE pg_class.relname = '#{table}'
        AND pg_namespace.nspname = '#{schema}'
    SQL
  end


# private

  def to_schema_and_table(table_name)
    table, schema = table_name.to_s.split(".", 2).reverse
    schema ||= "public"
    [schema, table]
  end
  private :to_schema_and_table

  def connection
    @connection || ActiveRecord::Base.connection
  end
  private :connection
end
