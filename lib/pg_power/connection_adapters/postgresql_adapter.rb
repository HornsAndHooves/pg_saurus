module PgPower
  module ConnectionAdapters
    module PostgreSQLAdapter
      def supports_comments?
        true
      end

      def set_table_comment(table_name, comment)
        sql = "COMMENT ON TABLE #{quote_table_name(table_name)} IS $$#{comment}$$;"
        execute sql
      end

      def set_column_comment(table_name, column_name, comment)
        sql = "COMMENT ON COLUMN #{quote_table_name(table_name)}.#{quote_column_name(column_name)} IS $$#{comment}$$;"
        execute sql
      end

      def set_column_comments(table_name, comments)
        comments.each_pair do |column_name, comment|
          set_column_comment table_name, column_name, comment
        end
      end

      def remove_table_comment(table_name)
        sql = "COMMENT ON TABLE #{quote_table_name(table_name)} IS NULL;"
        execute sql
      end

      def remove_column_comment(table_name, column_name)
        sql = "COMMENT ON COLUMN #{quote_table_name(table_name)}.#{quote_column_name(column_name)} IS NULL;"
        execute sql
      end

      def remove_column_comments(table_name, *column_names)
        column_names.each do |column_name|
          remove_column_comment table_name, column_name
        end
      end

      def comments(table_name)
        relation_name, schema_name = table_name.split(".", 2).reverse
        schema_name ||= "public" 

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
    end
  end
end

[:PostgreSQLAdapter, :JdbcAdapter].each do |adapter|
  begin
    ActiveRecord::ConnectionAdapters.const_get(adapter).class_eval do
      include PgPower::ConnectionAdapters::PostgreSQLAdapter
    end
  rescue
  end
end
