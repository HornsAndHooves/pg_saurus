module ActiveRecord
  module ConnectionAdapters
    # PostgreSQL-specific extensions to column definitions in a table.
    class PostgreSQLColumn < Column #:nodoc:
      # # == Patch 1:
      # # Remove schema name part from table name when sequence name doesn't include it.
      # def serial?
      #   return unless default_function

      #   if %r{\Anextval\('"?(?<sequence_name>.+_(?<suffix>seq\d*))"?'::regclass\)\z} =~ default_function
      #     is_schema_name_included = sequence_name.split(".").size > 1
      #     _table_name = is_schema_name_included ? table_name : table_name.split(".").last

      #     sequence_name_from_parts(_table_name, name, suffix) == sequence_name
      #   end
      # end
    end
  end
end
