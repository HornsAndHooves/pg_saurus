module ActiveRecord
  module ConnectionAdapters
    # Patched methods::
    #   * indexes
    class PostgreSQLAdapter
      # Returns an array of indexes for the given table.
      #
      # == Patch reason:
      # Since {ActiveRecord::SchemaDumper#tables} patched to process tables
      # with schema prefix {#indexes} method receives table_name as "<schema>.<table>".
      # So it should know how to handle table names with schema prefix.
      #
      # == Patch:
      #   schemas = schema_search_path.split(/,/).map { |p| quote(p) }.join(',')
      # Changed to:
      #   if table_name =~ /\./
      #     schemas, table = table_name.split(".")
      #     schemas = "'#{schemas}'"
      #   else
      #     schemas = schema_search_path.split(/,/).map { |p| quote(p) }.join(',')
      #     table = table_name
      #   end
      def indexes(table_name, name = nil)
        if table_name =~ /\./
          schemas, table = table_name.split(".")
          schemas = "'#{schemas}'"
        else
          schemas = schema_search_path.split(/,/).map { |p| quote(p) }.join(',')
          table = table_name
        end

        result = query(<<-SQL, name)
          SELECT distinct i.relname, d.indisunique, d.indkey, t.oid
          FROM pg_class t
          INNER JOIN pg_index d ON t.oid = d.indrelid
          INNER JOIN pg_class i ON d.indexrelid = i.oid
          WHERE i.relkind = 'i'
            AND d.indisprimary = 'f'
            AND t.relname = '#{table}'
            AND i.relnamespace IN (SELECT oid FROM pg_namespace WHERE nspname IN (#{schemas}) )
         ORDER BY i.relname
        SQL


        result.map do |row|
          index_name = row[0]
          unique = row[1] == 't'
          indkey = row[2].split(" ")
          oid = row[3]

          columns = Hash[query(<<-SQL, "Columns for index #{row[0]} on #{table_name}")]
          SELECT a.attnum, a.attname
          FROM pg_attribute a
          WHERE a.attrelid = #{oid}
          AND a.attnum IN (#{indkey.join(",")})
          SQL

          column_names = columns.values_at(*indkey).compact
          column_names.empty? ? nil : IndexDefinition.new(table_name, index_name, unique, column_names)
        end.compact
      end

    end
  end
end
