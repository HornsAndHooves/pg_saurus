module ActiveRecord # :nodoc:
  module ConnectionAdapters # :nodoc:
    # Patched version:  5.2.3
    # Patched methods::
    #   * indexes
    class PostgreSQLAdapter
      # Regex to find columns used in index statements
      INDEX_COLUMN_EXPRESSION = /ON [\w\.]+(?: USING \w+ )?\((.+)\)/
      # Regex to find where clause in index statements
      INDEX_WHERE_EXPRESSION = /WHERE (.+)$/

      # Returns an array of indexes for the given table.
      #
      # == Patch 1:
      # Remove type specification from stored Postgres index definitions.
      #
      # == Patch 2:
      # Split compound functional indexes to array.
      #
      def indexes(table_name)
        scope = quoted_scope(table_name)

        result = query(<<-SQL, "SCHEMA")
          SELECT distinct i.relname, d.indisunique, d.indkey, pg_get_indexdef(d.indexrelid), t.oid,
                          pg_catalog.obj_description(i.oid, 'pg_class') AS comment
          FROM pg_class t
          INNER JOIN pg_index     d  ON t.oid = d.indrelid
          INNER JOIN pg_class     i  ON d.indexrelid = i.oid
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
          comment = row[5]

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
            comment: comment.presence
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
