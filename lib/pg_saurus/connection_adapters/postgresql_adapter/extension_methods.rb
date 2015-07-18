# Provides methods to extend {ActiveRecord::ConnectionAdapters::PostgreSQLAdapter}
# to support extensions feature.
module PgSaurus::ConnectionAdapters::PostgreSQLAdapter::ExtensionMethods
  # Default options for {#create_extension} method.
  CREATE_EXTENSION_DEFAULTS = {
      :if_not_exists => true,
      :schema_name   => nil,
      :version       => nil,
      :old_version   => nil
  }

  # Default options for {#drop_extension} method.
  DROP_EXTENSION_DEFAULTS = {
      :if_exists => true,
      :mode      => :restrict
  }

  # The modes which determine postgresql behavior on DROP EXTENSION operation.
  #
  # *:restrict* refuse to drop the extension if any objects depend on it
  # *:cascade* automatically drop objects that depend on the extension
  AVAILABLE_DROP_MODES = {
      :restrict => 'RESTRICT',
      :cascade  => 'CASCADE'
  }

  # @return [Boolean] if adapter supports postgresql extension manipulation
  def supports_extensions?
    true
  end

  # Execute SQL to load a postgresql extension module into the current database.
  #
  # @param [#to_s] extension_name Name of the extension module to load
  # @param [Hash] options
  # @option options [Boolean] :if_not_exists should the 'IF NOT EXISTS' clause be added
  # @option options [#to_s,nil] :schema_name The name of the schema in which to install the extension's objects
  # @option options [#to_s,nil] :version The version of the extension to install
  # @option options [#to_s,nil] :old_version Alternative installation script name
  #    that absorbs the existing objects into the extension, instead of creating new objects
  def create_extension(extension_name, options = {})
    options = CREATE_EXTENSION_DEFAULTS.merge(options.symbolize_keys)

    sql = ['CREATE EXTENSION']
    sql << 'IF NOT EXISTS'                   if options[:if_not_exists]
    sql << %Q{"#{extension_name.to_s}"}
    sql << "SCHEMA #{options[:schema_name]}" if options[:schema_name].present?
    sql << "VERSION '#{options[:version]}'"  if options[:version].present?
    sql << "FROM #{options[:old_version]}"   if options[:old_version].present?

    sql = sql.join(' ')
    execute(sql)
  end

  # Execute SQL to load a postgresql extension module into the current database
  # if it does not already exist. Then reload the type map.
  #
  # @param [#to_s] extension_name Name of the extension module to load
  # @param [Hash] options
  # @option options [#to_s,nil] :schema_name The name of the schema in which to install the extension's objects
  # @option options [#to_s,nil] :version The version of the extension to install
  # @option options [#to_s,nil] :old_version Alternative installation script name
  #    that absorbs the existing objects into the extension, instead of creating new objects
  def enable_extension(extension_name, options = {})
    options[:if_not_exists] = true
    create_extension(extension_name, options).tap { reload_type_map }
  end

  # Execute SQL to remove a postgresql extension module from the current database.
  #
  # @param [#to_s] extension_name Name of the extension module to unload
  # @param [Hash] options
  # @option options [Boolean] :if_exists should the 'IF EXISTS' clause be added
  # @option options [Symbol] :mode Operation mode. See {AVAILABLE_DROP_MODES} for details
  def drop_extension(extension_name, options = {})
    options = DROP_EXTENSION_DEFAULTS.merge(options.symbolize_keys)

    sql = ['DROP EXTENSION']
    sql << 'IF EXISTS' if options[:if_exists]
    sql << %Q{"#{extension_name.to_s}"}

    mode = options[:mode]
    if mode.present?
      mode = mode.to_sym

      unless AVAILABLE_DROP_MODES.include?(mode)
        raise ArgumentError,
              "Expected one of #{AVAILABLE_DROP_MODES.keys.inspect} drop modes, " \
              "but #{mode} received"
      end

      sql << AVAILABLE_DROP_MODES[mode]
    end

    sql = sql.join(' ')
    execute(sql)
  end

  # Query the pg_catalog for all extension modules loaded to the current database.
  #
  # @note
  #   Since Rails 4 connection has method +extensions+ that returns array of extensions.
  #   This method is slightly different, since it returns also additional options.
  #
  # Please note all extensions which belong to pg_catalog schema are omitted
  # ===Example
  #
  #   extension # => {
  #     "fuzzystrmatch" => {:schema_name => "public", :version => "1.0" }
  #   }
  #
  # @return [Hash{String => Hash{Symbol => String}}] A list of loaded extensions with their options
  def pg_extensions
    # Check postgresql version to not break on Postgresql < 9.1 during schema dump
    pg_version_str = select_value('SELECT version()')
    return {} unless pg_version_str =~ /^PostgreSQL (\d+\.\d+.\d+)/ && ($1 >= '9.1')

    sql = <<-SQL
      SELECT pge.extname AS ext_name, pgn.nspname AS schema_name, pge.extversion AS ext_version
      FROM pg_extension pge
      INNER JOIN pg_namespace pgn on pge.extnamespace = pgn.oid
      WHERE pgn.nspname <> 'pg_catalog'
    SQL

    result = select_all(sql)
    formatted_result = result.map do |row|
      [
          row['ext_name'],
          {
              :schema_name => row['schema_name'],
              :version => row['ext_version']
          }
      ]
    end

    Hash[formatted_result]
  end
end
