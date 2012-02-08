# Provides methods to extend {ActiveRecord::ConnectionAdapters::PostgreSQLAdapter}
# to support foreign keys feature.
module PgPower::ConnectionAdapters::PostgreSQLAdapter::ForeignerMethods
  def supports_foreign_keys?
    true
  end

  # Fetches information about foreign keys related to passed table.
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

      PgPower::ConnectionAdapters::ForeignKeyDefinition.new(table_name, row['to_table'], options)
    end
  end

  # Disables triggers and drops tables.
  def drop_table(*args)
    disable_referential_integrity { super }
  end

  # Adds foreign key.
  #
  # == Options:
  # * :column
  # * :primary_key
  # * :dependent
  #
  # @param [String, Symbol] from_table 
  # @param [String, Symbol] to_table
  # @param [Hash] options
  def add_foreign_key(from_table, to_table, options = {})
    sql = "ALTER TABLE #{quote_table_name(from_table)} #{add_foreign_key_sql(from_table, to_table, options)}"
    execute(sql)
  end

  # Returns chunk of SQL to add foreign key based on table names and options.
  def add_foreign_key_sql(from_table, to_table, options = {})
    column = options[:column] || "#{to_table.to_s.split('.').last.singularize}_id"
    foreign_key_name = foreign_key_name(from_table, column, options)
    primary_key = options[:primary_key] || "id"
    dependency = dependency_sql(options[:dependent])

    sql =
      "ADD CONSTRAINT #{quote_column_name(foreign_key_name)} " +
      "FOREIGN KEY (#{quote_column_name(column)}) " +
      "REFERENCES #{quote_table_name(ActiveRecord::Migrator.proper_table_name(to_table))}(#{primary_key})"
    sql << " #{dependency}" if dependency.present?
    sql << " #{options[:options]}" if options[:options]

    sql
  end

  # Removes foreign key.
  # @param [String, Symbol] table
  # @param [Hash] options
  def remove_foreign_key(table, options)
    execute "ALTER TABLE #{quote_table_name(table)} #{remove_foreign_key_sql(table, options)}"
  end

  # Returns chunk of SQL to  remove foreign key based on table name and options.
  def remove_foreign_key_sql(table, options)
    if Hash === options
      foreign_key_name = foreign_key_name(table, options[:column], options)
    else
      column = "#{options.to_s.split('.').last.singularize}_id"
      foreign_key_name = foreign_key_name(table, column)
    end

    "DROP CONSTRAINT #{quote_column_name(foreign_key_name)}"
  end



  # Builds default name for constraint
  def foreign_key_name(table, column, options = {})
    if options[:name]
      options[:name]
    else
      prefix = table.gsub(".", "_")
      "#{prefix}_#{column}_fk"
    end
  end
  private :foreign_key_name

  def dependency_sql(dependency)
    case dependency
      when :nullify then "ON DELETE SET NULL"
      when :delete then "ON DELETE CASCADE"
      when :restrict then "ON DELETE RESTRICT"
      else ""
    end
  end
  private :dependency_sql
end
