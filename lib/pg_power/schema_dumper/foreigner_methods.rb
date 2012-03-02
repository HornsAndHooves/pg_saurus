# Provides methods to extend {ActiveRecord::SchemaDumper} to dump
# foreign keys.
module PgPower::SchemaDumper::ForeignerMethods
  # Hooks {ActiveRecord::SchemaDumper#table} method to dump foreign keys.
  def tables_with_foreign_keys(stream)
    tables_without_foreign_keys(stream)

    table_names = @connection.tables.sort
    table_names += get_non_public_schema_table_names.sort

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


  # Finds all foreign keys on passed table and writes appropriated
  # statements to stream.
  def foreign_keys(table_name, stream)
    if (foreign_keys = @connection.foreign_keys(table_name)).any?
      add_foreign_key_statements = foreign_keys.map do |foreign_key|
        statement_parts = [ ('add_foreign_key ' + foreign_key.from_table.inspect) ]
        statement_parts << foreign_key.to_table.inspect
        statement_parts << (':name => ' + foreign_key.options[:name].inspect)

        if foreign_key.options[:column] != "#{foreign_key.to_table.singularize}_id"
          statement_parts << (':column => ' + foreign_key.options[:column].inspect)
        end
        if foreign_key.options[:primary_key] != 'id'
          statement_parts << (':primary_key => ' + foreign_key.options[:primary_key].inspect)
        end
        if foreign_key.options[:dependent].present?
          statement_parts << (':dependent => ' + foreign_key.options[:dependent].inspect)
        end

        # Always exclude the index
        #  If an index was created in a migration, it will get dumped to the schema
        #  separately from the foreign key.  This will raise an exception if
        #  add_foreign_key is run without :exclude_index => true.
        statement_parts << (':exclude_index => true')

        ' ' + statement_parts.join(', ')
      end

      stream.puts add_foreign_key_statements.sort.join("\n")
      stream.puts
    end
  end
  private :foreign_keys
end
