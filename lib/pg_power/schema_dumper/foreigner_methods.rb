module PgPower::SchemaDumper::ForeignerMethods

  def tables_with_non_public_foreign_keys(stream)
    tables_without_non_public_foreign_keys(stream)

    get_non_public_schema_table_names.sort.each do |table|
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

end