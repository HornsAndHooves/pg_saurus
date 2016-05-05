# Provides methods to extend ActiveRecord::SchemaDumper to dump
# foreign keys.
module PgSaurus::SchemaDumper::ForeignKeyMethods

  # See activerecord/lib/active_record/schema_dumper.rb
  def foreign_keys_with_indexes(table, stream)
    if (foreign_keys = @connection.foreign_keys(table)).any?
      add_foreign_key_statements = foreign_keys.map do |foreign_key|

        from_table = if foreign_key.from_schema && foreign_key.from_schema != 'public'
                       "#{foreign_key.from_schema}.#{remove_prefix_and_suffix(foreign_key.from_table)}"
                     else
                       remove_prefix_and_suffix(foreign_key.from_table)
                     end

        parts = [
          "add_foreign_key #{from_table.inspect}",
          remove_prefix_and_suffix(foreign_key.to_table).inspect,
        ]

        if foreign_key.column != @connection.foreign_key_column_for(foreign_key.to_table)
          parts << "column: #{foreign_key.column.inspect}"
        end

        if foreign_key.custom_primary_key?
          parts << "primary_key: #{foreign_key.primary_key.inspect}"
        end

        if foreign_key.name !~ /^fk_rails_[0-9a-f]{10}$/
          parts << "name: #{foreign_key.name.inspect}"
        end

        parts << "on_update: #{foreign_key.on_update.inspect}" if foreign_key.on_update
        parts << "on_delete: #{foreign_key.on_delete.inspect}" if foreign_key.on_delete

        # Always exclude the index
        #  If an index was created in a migration, it will get dumped to the schema
        #  separately from the foreign key.  This will raise an exception if
        #  add_foreign_key is run without :exclude_index => true.
        parts << ":exclude_index => true"

        "  #{parts.join(', ')}"
      end

      stream.puts add_foreign_key_statements.sort.join("\n")
    end
  end

end
