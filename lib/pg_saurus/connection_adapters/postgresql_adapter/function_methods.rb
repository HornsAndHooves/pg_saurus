# Provides methods to extend {ActiveRecord::ConnectionAdapters::PostgreSQLAdapter}
# to support database functions.
module PgSaurus::ConnectionAdapters::PostgreSQLAdapter::FunctionMethods

  # returns true
  def supports_functions?
    true
  end

  # Returns a list of defined db functions. Ignores function definitions that can't
  # be parsed.
  def functions
    res = select_all <<-SQL
      SELECT n.nspname as "Schema",
        p.proname as "Name",
        pg_catalog.pg_get_function_result(p.oid) as "Returning",
       CASE
        WHEN p.proisagg THEN 'agg'
        WHEN p.proiswindow THEN 'window'
        WHEN p.prorettype = 'pg_catalog.trigger'::pg_catalog.regtype THEN 'trigger'
        ELSE 'normal'
       END as "Type",
       p.oid as "Oid"
      FROM pg_catalog.pg_proc p
           LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
      WHERE pg_catalog.pg_function_is_visible(p.oid)
            AND n.nspname <> 'pg_catalog'
            AND n.nspname <> 'information_schema'
      ORDER BY 1, 2, 3, 4;
    SQL
    res.inject([]) do |buffer, row|
      returning     = row['Returning']
      function_type = row['Type']
      oid           = row['Oid']

      function_str = select_value("SELECT pg_get_functiondef(#{oid});")

      name       = parse_function_name(function_str)
      language   = parse_function_language(function_str)
      definition = parse_function_definition(function_str)

      if definition
        buffer << ::PgSaurus::ConnectionAdapters::FunctionDefinition.new(name,
                                                                         returning,
                                                                         definition.strip,
                                                                         function_type,
                                                                         language,
                                                                         oid)
      end
      buffer
    end
  end

  # Create a new database function
  def create_function(function_name, returning, definition, options = {})
    function_name = full_function_name(function_name, options)
    language = options[:language] || 'plpgsql'
    replace = if options[:replace] == false
                ''
              else
                'OR REPLACE '
              end

    sql = <<-SQL
CREATE #{replace}FUNCTION #{function_name}
  RETURNS #{returning}
  LANGUAGE #{language}
AS $function$
#{definition.strip}
$function$
    SQL

    execute(sql)
  end

  # Drops the given database function
  def drop_function(function_name, options = {})
    function_name = full_function_name(function_name, options)

    execute "DROP FUNCTION #{function_name}"
  end

  def parse_function_name(function_str)
    function_str.split("\n").find { |line| line =~ /^CREATE[\s\S]+FUNCTION/ }.split(' ').last
  end
  private :parse_function_name

  def parse_function_language(function_str)
    function_str.split("\n").find { |line| line =~ /LANGUAGE/ }.split(' ').last
  end
  private :parse_function_language

  def parse_function_definition(function_str)
    function_str[/#{Regexp.escape("AS $function$\n")}(.*?)#{Regexp.escape("$function$")}/m,1]
  end
  private :parse_function_definition

  # Write out the fully qualified function name if the schema option is passed.
  def full_function_name(function_name, options)
    schema        = options[:schema]
    function_name = "#{schema}.#{function_name}" if schema
    function_name
  end
  private :full_function_name
end
