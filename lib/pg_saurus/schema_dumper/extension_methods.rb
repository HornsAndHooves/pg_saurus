# Extends ActiveRecord::SchemaDumper class to dump comments on tables and columns.
module PgSaurus::SchemaDumper::ExtensionMethods
  # Hook ActiveRecord::SchemaDumper#header method to dump extensions in all
  # schemas except for pg_catalog.
  def header_with_extensions(stream)
    header_without_extensions(stream)
    dump_extensions(stream)
    stream
  end

# Dump current database extensions recreation commands to the given stream.
#
# @param [#puts] stream Stream to write to
  def dump_extensions(stream)
    extensions = @connection.pg_extensions
    commands   = extensions.map do |extension_name, options|
      result = [%Q|create_extension "#{extension_name}"|]
      result << %Q|:schema_name => "#{options[:schema_name]}"| unless options[:schema_name] == 'public'
      result << %Q|:version => "#{options[:version]}"|
      result.join(', ')
    end

    commands.each do |command|
      stream.puts("  #{command}")
    end

    stream.puts
  end
end
