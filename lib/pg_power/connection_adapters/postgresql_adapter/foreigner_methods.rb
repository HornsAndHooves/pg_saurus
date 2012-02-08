# Obtains {#add_foreign_key} and {#remove_foreign_key} methods provided by 
# foreigner gem to correctly calculate column name when table with schema
# prefix is passed.
module PgPower::ConnectionAdapters::PostgreSQLAdapter::ForeignerMethods
  # Forces {#add_foreign_key} to use :column option calculated from
  # table name if it was not passed explicitly.
  def add_foreign_key_sql_with_column(from_table, to_table, options = {})
    column = "#{to_table.to_s.split('.').last.singularize}_id"
    options[:column] ||= column
    add_foreign_key_sql_without_column(from_table, to_table, options)
  end


  # Forces {#remove_foreign_key} to use :column option calculated from
  # table name if it was not passed explicitly.
  def remove_foreign_key_sql_with_column(table, options_or_table)
    if Hash === options_or_table
      options = options_or_table
    else
      column = "#{options_or_table.to_s.split('.').last.singularize}_id"
      options = {:column => column}
    end
    remove_foreign_key_sql_without_column(table, options)
  end

  # Redefinition of {Foreigner::ConnectionAdapters::PostgreSQLAdapter#foreign_keys}.
  # Processes table_name with schema prefix correctly.
  # @param [String, Symbol] table_name name of table (e.g. "users", "music.bands")
  # @return [Foreigner::ConnectionAdapters::ForeignKeyDefinition] 
  def foreign_keys(table_name)
    relation, schema = table_name.to_s.split('.', 2).reverse
    quoted_schema = schema ? "'#{schema}'" : "ANY (current_schemas(false))" 

    fk_info = select_all <<-SQL
      SELECT t2.relname AS to_table, a1.attname AS column, a2.attname AS primary_key, c.conname AS name, c.confdeltype AS dependency
      FROM pg_constraint c
      JOIN pg_class t1 ON c.conrelid = t1.oid
      JOIN pg_class t2 ON c.confrelid = t2.oid
      JOIN pg_attribute a1 ON a1.attnum = c.conkey[1] AND a1.attrelid = t1.oid
      JOIN pg_attribute a2 ON a2.attnum = c.confkey[1] AND a2.attrelid = t2.oid
      JOIN pg_namespace t3 ON c.connamespace = t3.oid
      WHERE c.contype = 'f'
      AND t1.relname = '#{relation}'
      AND t3.nspname = #{quoted_schema}
      ORDER BY c.conname
    SQL
    
    fk_info.map do |row|
      options = {:column => row['column'], :name => row['name'], :primary_key => row['primary_key']}

      options[:dependent] = case row['dependency']
        when 'c' then :delete
        when 'n' then :nullify
        when 'r' then :restrict
      end

      Foreigner::ConnectionAdapters::ForeignKeyDefinition.new(table_name, row['to_table'], options)
    end
  end
end
