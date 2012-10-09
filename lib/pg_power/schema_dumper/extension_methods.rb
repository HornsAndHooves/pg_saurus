# Extends ActiveRecord::SchemaDumper class to dump comments on tables and columns.
module PgPower::SchemaDumper::ExtensionMethods
  # Hooks {ActiveRecord::SchemaDumper#table} method to dump extensions in all schemas except for pg_catalog
  def tables_with_extensions(stream)
    dump_extensions(stream)
    tables_without_extensions(stream)
  end

  # Dump current database extensions recreation commands to the given stream
  #
  # @param [#puts] stream Stream to write to
  def dump_extensions(stream)
    extensions = @connection.extensions
    commands = extensions.map do |extension_name, options|
      "create_extension '#{extension_name}', :schema => '#{options[:schema_name]}', :version => '#{options[:version]}'"
    end

    commands.each do |c|
      stream.puts("  " + c)
    end

    stream.puts
  end
end