# Extends ActiveRecord::SchemaDumper class to dump comments on tables and columns.
module PgSaurus::SchemaDumper::ExtensionMethods
  # Overrides https://github.com/rails/rails/blob/v7.2.2.2/activerecord/lib/active_record/connection_adapters/postgresql/schema_dumper.rb#L8
  #
  # Dump current database extensions recreation commands to the given stream.
  #
  # @param [#puts] stream Stream to write to
  def extensions(stream)
    extensions = @connection.pg_extensions
    commands   = extensions.map do |extension_name, options|
      result = [%Q|create_extension "#{extension_name}"|]
      result << %Q|schema_name: "#{options[:schema_name]}"| unless options[:schema_name] == 'public'
      result << %Q|version: "#{options[:version]}"|
      result.join(', ')
    end

    commands.each do |command|
      stream.puts("  #{command}")
    end

    stream.puts

    super
  end
end
