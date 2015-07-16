# Provides methods to extend ActiveRecord::SchemaDumper to dump
# foreign keys.
module PgSaurus::SchemaDumper::ForeignerMethods
  # Hooks ActiveRecord::SchemaDumper#table method to dump foreign keys.
  def tables_with_foreign_keys(stream)
    tables_without_foreign_keys(stream)

    table_names = @connection.tables.sort

    table_names.sort.each do |table|
      next if ['schema_migrations', ignore_tables].flatten.any? do |ignored|
        case ignored
        when String; table == ignored
        when Regexp; table =~ ignored
        else
          raise StandardError, 'ActiveRecord::SchemaDumper.ignore_tables accepts an array of String and / or Regexp values.'
        end
      end
      foreign_keys(table, stream)
    end
  end


  # Find all foreign keys on passed table and writes appropriate
  # statements to stream.
  def foreign_keys(table_name, stream)
    if (foreign_keys = @connection.foreign_keys(table_name)).any?
      add_foreign_key_statements = foreign_keys.map do |foreign_key|
        options         = foreign_key.options
        table_from_key  = foreign_key.to_table
        statement_parts = [ ('add_foreign_key ' + foreign_key.from_table.inspect) ]
        statement_parts << table_from_key.inspect
        statement_parts << (':name => ' + options[:name].inspect)

        column_from_options      = options[:column]
        primary_key_from_options = options[:primary_key]
        dependent_from_options   = options[:dependent]

        if column_from_options != "#{table_from_key.singularize}_id"
          statement_parts << (":column => #{column_from_options.inspect}")
        end
        if primary_key_from_options != 'id'
          statement_parts << (":primary_key => #{primary_key_from_options.inspect}")
        end
        if dependent_from_options.present?
          statement_parts << (":dependent => #{dependent_from_options.inspect}")
        end

        # Always exclude the index
        #  If an index was created in a migration, it will get dumped to the schema
        #  separately from the foreign key.  This will raise an exception if
        #  add_foreign_key is run without :exclude_index => true.
        statement_parts << (':exclude_index => true')

        '  ' + statement_parts.join(', ')
      end

      stream.puts add_foreign_key_statements.sort.join("\n")
      stream.puts
    end
  end
  private :foreign_keys
end
