module PgPower # :nodoc:
  # Raised when an unexpected index exists
  class IndexExistsError < StandardError
  end

  # Provides methods to extend {ActiveRecord::ConnectionAdapters::PostgreSQLAdapter}
  # to support foreign keys feature.
  module ConnectionAdapters::PostgreSQLAdapter::ForeignerMethods
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
        SELECT nsp.nspname || '.' || t2.relname AS to_table,
               a1.attname    AS column     ,
               a2.attname    AS primary_key,
               c.conname     AS name       ,
               c.confdeltype AS dependency
        FROM pg_constraint c
        JOIN pg_class t1 ON c.conrelid = t1.oid
        JOIN pg_class t2 ON c.confrelid = t2.oid
        JOIN pg_attribute a1 ON a1.attnum = c.conkey[1] AND a1.attrelid = t1.oid
        JOIN pg_attribute a2 ON a2.attnum = c.confkey[1] AND a2.attrelid = t2.oid
        JOIN pg_namespace t3 ON c.connamespace = t3.oid
        JOIN pg_namespace nsp ON nsp.oid = t2.relnamespace
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
    # Ensures that an index is created for the foreign key, unless :exclude_index is true.
    #
    # Raises a [PgPower::IndexExistsError] when :exclude_index is true, but the index already exists.
    #
    # == Options:
    # * :column
    # * :primary_key
    # * :dependent
    # * :exclude_index [Boolean]
    #
    # @param [String, Symbol] from_table
    # @param [String, Symbol] to_table
    # @param [Hash] options
    #
    def add_foreign_key(from_table, to_table, options = {})
      options[:column] ||= id_column_name_from_table_name(to_table)
      options[:exclude_index] ||= false

      if index_exists?(from_table, options[:column]) and !options[:exclude_index]
        raise PgPower::IndexExistsError, "The index, #{index_name(from_table, options[:column])}, already exists.  Use :exclude_index => true when adding the foreign key."
      end

      sql = "ALTER TABLE #{quote_table_name(from_table)} #{add_foreign_key_sql(from_table, to_table, options)}"
      execute(sql)

      add_index(from_table, options[:column]) unless options[:exclude_index]
    end

    # Returns chunk of SQL to add foreign key based on table names and options.
    def add_foreign_key_sql(from_table, to_table, options = {})
      foreign_key_name = foreign_key_name(from_table, options[:column], options)
      primary_key = options[:primary_key] || "id"
      dependency = dependency_sql(options[:dependent])

      sql =
        "ADD CONSTRAINT #{quote_column_name(foreign_key_name)} " +
        "FOREIGN KEY (#{quote_column_name(options[:column])}) " +
        "REFERENCES #{quote_table_name(ActiveRecord::Migrator.proper_table_name(to_table))}(#{primary_key})"
      sql << " #{dependency}" if dependency.present?
      sql << " #{options[:options]}" if options[:options]

      sql
    end

    #
    # TODO Determine if we can refactor the method signature
    #   remove_foreign_key(from_table, to_table_or_options_hash, options={}) => remove_foreign_key(from_table, to_table, options={})
    #
    # Removes foreign key.
    # @param [String, Symbol] from_table
    # @param [String, Hash] to_table_or_options_hash
    #
    def remove_foreign_key(from_table, to_table_or_options_hash, options={})
      if Hash === to_table_or_options_hash
        options = to_table_or_options_hash
        column = options[:column]
        foreign_key_name = foreign_key_name(from_table, column, options)
        column ||= id_column_name_from_foreign_key_metadata(from_table, foreign_key_name)
      else
        column = id_column_name_from_table_name(to_table_or_options_hash)
        foreign_key_name = foreign_key_name(from_table, column)
      end

      execute "ALTER TABLE #{quote_table_name(from_table)} #{remove_foreign_key_sql(foreign_key_name)}"

      options[:exclude_index] ||= false
      remove_index(from_table, column) unless options[:exclude_index] || !index_exists?(from_table, column)
    end

    # Returns chunk of SQL to  remove foreign key based on table name and options.
    def remove_foreign_key_sql(foreign_key_name)
      "DROP CONSTRAINT #{quote_column_name(foreign_key_name)}"
    end

    # Builds the foreign key column id from the referenced table
    def id_column_name_from_table_name(table)
      "#{table.to_s.split('.').last.singularize}_id"
    end
    private :id_column_name_from_table_name

    # Extracts the foreign key column id from the foreign key metadata
    # @param [String, Symbol] from_table
    # @param [String]         foreign_key_name
    def id_column_name_from_foreign_key_metadata(from_table, foreign_key_name)
      keys = foreign_keys(from_table)
      this_key = keys.find {|key| key.options[:name] == foreign_key_name}
      this_key.options[:column]
    end
    private :id_column_name_from_foreign_key_metadata
    
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
end
