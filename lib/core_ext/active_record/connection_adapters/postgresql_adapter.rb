module ActiveRecord # :nodoc:
  module ConnectionAdapters # :nodoc:
    # Patched version:  3.1.3
    # Patched methods::
    #   * indexes
    class PostgreSQLAdapter

      # Returns an array of indexes for the given table.
      #
      # == Patch 1 reason:
      # Since {ActiveRecord::SchemaDumper#tables} is patched to process tables
      # with a schema prefix, the {#indexes} method receives table_name as
      # "<schema>.<table>". This patch allows it to handle table names with
      # a schema prefix.
      #
      # == Patch 1:
      # Search using provided schema if table_name includes schema name.
      #
      # == Patch 2 reason:
      # {ActiveRecord::ConnectionAdapters::PostgreSQLAdapter#indexes} is patched
      # to support partial indexes using :where clause.
      #
      # == Patch 2:
      # Search the postgres indexdef for the where clause and pass the output to
      # the custom {PgPower::ConnectionAdapters::IndexDefinition}
      #
      def indexes(table_name, name = nil)
        schema, table = extract_schema_and_table(table_name)
        schemas = schema ? "ARRAY['#{schema}']" : 'current_schemas(false)'

        result = query(<<-SQL, name)
          SELECT distinct i.relname, d.indisunique, d.indkey,  pg_get_indexdef(d.indexrelid), t.oid
          FROM pg_class t
          INNER JOIN pg_index d ON t.oid = d.indrelid
          INNER JOIN pg_class i ON d.indexrelid = i.oid
          WHERE i.relkind = 'i'
            AND d.indisprimary = 'f'
            AND t.relname = '#{table}'
            AND i.relnamespace IN (SELECT oid FROM pg_namespace WHERE nspname = ANY (#{schemas}) )
         ORDER BY i.relname
        SQL

        result.map do |row|
          index_name = row[0]
          unique = row[1] == 't'
          indkey = row[2].split(" ")
          inddef = row[3]
          oid = row[4]

          columns = Hash[query(<<-SQL, "Columns for index #{row[0]} on #{table_name}")]
          SELECT a.attnum, a.attname
          FROM pg_attribute a
          WHERE a.attrelid = #{oid}
          AND a.attnum IN (#{indkey.join(",")})
          SQL

          column_names = columns.values_at(*indkey).compact

          where = inddef.scan(/WHERE (.+)$/).flatten[0]

          # TODO Update lengths once we merge in ActiveRecord code that supports it.
          lengths = []
          column_names.empty? ? nil : PgPower::ConnectionAdapters::IndexDefinition.new(table_name, index_name, unique, column_names, lengths, where)
        end.compact
      end

    end
  end
end
