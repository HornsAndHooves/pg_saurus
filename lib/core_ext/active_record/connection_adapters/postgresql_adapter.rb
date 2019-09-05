module ActiveRecord # :nodoc:
  module ConnectionAdapters # :nodoc:
    # Patched version:  3.1.3
    # Patched methods::
    #   * indexes
    class PostgreSQLAdapter
      # Regex to find columns used in index statements
      INDEX_COLUMN_EXPRESSION = /ON [\w\.]+(?: USING \w+ )?\((.+)\)/
      # Regex to find where clause in index statements
      INDEX_WHERE_EXPRESSION = /WHERE (.+)$/

      # Returns the list of all tables in the schema search path or a specified schema.
      #
      # == Patch:
      # If current user is not `postgres` original method return all tables from all schemas
      # without schema prefix. This disables such behavior by querying only default schema.
      # Tables with schemas will be queried later.
      #
      def tables(name = nil)
        query(<<-SQL, 'SCHEMA').map { |row| row[0] }
            SELECT tablename
            FROM pg_tables
            WHERE schemaname = ANY (ARRAY['public'])
        SQL
      end

      # Checks if index exists for given table.
      #
      # == Patch:
      # Search using provided schema if table_name includes schema name.
      #
      def index_name_exists?(table_name, index_name, default = nil)
        postgre_sql_name = PostgreSQL::Utils.extract_schema_qualified_name(table_name)
        schema, table = postgre_sql_name.schema, postgre_sql_name.identifier
        schemas = schema ? "ARRAY['#{schema}']" : 'current_schemas(false)'

        exec_query(<<-SQL, 'SCHEMA').rows.first[0].to_i > 0
          SELECT COUNT(*)
          FROM pg_class t
          INNER JOIN pg_index d ON t.oid = d.indrelid
          INNER JOIN pg_class i ON d.indexrelid = i.oid
          WHERE i.relkind = 'i'
            AND i.relname = '#{index_name}'
            AND t.relname = '#{table}'
            AND i.relnamespace IN (SELECT oid FROM pg_namespace WHERE nspname = ANY (#{schemas}) )
        SQL
      end

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
      # the custom {PgSaurus::ConnectionAdapters::IndexDefinition}
      #
      def indexes(table_name)
        scope = quoted_scope(table_name)

        result = query(<<-SQL, "SCHEMA")
          SELECT distinct i.relname, d.indisunique, d.indkey, pg_get_indexdef(d.indexrelid), t.oid,
                          am.amname, pg_catalog.obj_description(i.oid, 'pg_class') AS comment
          FROM pg_class t
          INNER JOIN pg_index     d  ON t.oid = d.indrelid
          INNER JOIN pg_class     i  ON d.indexrelid = i.oid
          INNER JOIN pg_am        am ON i.relam = am.oid
          LEFT JOIN  pg_namespace n  ON n.oid = i.relnamespace
          WHERE i.relkind = 'i'
            AND d.indisprimary = 'f'
            AND t.relname = #{scope[:name]}
            AND n.nspname = #{scope[:schema]}
          ORDER BY i.relname
        SQL

        result.map do |row|
          index_name = row[0]
          unique = row[1]
          indkey = row[2].split(" ").map(&:to_i)
          inddef = row[3]
          oid = row[4]
          access_method = row[5]
          comment = row[6]

          using, expressions, where = inddef.scan(/ USING (\w+?) \((.+?)\)(?: WHERE (.+))?\z/m).flatten

          orders = {}
          opclasses = {}

          if indkey.include?(0)
            definition = inddef.sub(INDEX_WHERE_EXPRESSION, '')

            if column_expression = definition.match(INDEX_COLUMN_EXPRESSION)[1]
              columns = split_expression(expressions).map do |functional_name|
                remove_type(functional_name)
              end

              columns = columns.size > 1 ? columns : columns[0]
            end
          else
            columns = Hash[query(<<-SQL.strip_heredoc, "SCHEMA")].values_at(*indkey).compact
              SELECT a.attnum, a.attname
              FROM pg_attribute a
              WHERE a.attrelid = #{oid}
              AND a.attnum IN (#{indkey.join(",")})
            SQL

            # add info on sort order (only desc order is explicitly specified, asc is the default)
            # and non-default opclasses
            expressions.scan(/(?<column>\w+)"?\s?(?<opclass>\w+_ops)?\s?(?<desc>DESC)?\s?(?<nulls>NULLS (?:FIRST|LAST))?/).each do |column, opclass, desc, nulls|
              opclasses[column] = opclass.to_sym if opclass

              if nulls
                orders[column] = [desc, nulls].compact.join(" ")
              else
                orders[column] = :desc if desc
              end
            end
          end

          PgSaurus::ConnectionAdapters::IndexDefinition.new(
            table_name,
            index_name,
            unique,
            columns,
            orders: orders,
            opclasses: opclasses,
            where: where,
            using: using.to_sym,
            comment: comment.presence,
            access_method: access_method
          )
        end
      end

      # Splits only on commas outside of parens
      def split_expression(expression)
        result = []
        parens = 0
        buffer = ""

        expression.chars do |char|
          case char
          when ','
            if parens == 0
              result.push(buffer)
              buffer = ""
              next
            end
          when '('
            parens += 1
          when ')'
            parens -= 1
          end

          buffer << char
        end

        result << buffer unless buffer.empty?
        result
      end

      # Find where statement from index definition
      #
      # @param [Hash] index index attributes
      # @return [String] where statement
      def find_where_statement(index)
        index[:definition].scan(INDEX_WHERE_EXPRESSION).flatten[0]
      end

      # Find length of index
      # TODO Update lengths once we merge in ActiveRecord code that supports it. -dresselm 20120305
      #
      # @param [Hash] index index attributes
      # @return [Array]
      def find_lengths(index)
        []
      end

      # Remove type specification from stored Postgres index definitions
      #
      # @param [String] column_with_type the name of the column with type
      # @return [String]
      #
      # @example
      #   remove_type("((col)::text")
      #   => "col"
      def remove_type(column_with_type)
        column_with_type.sub(/\((\w+)\)::\w+/, '\1')
      end
    end
  end
end
