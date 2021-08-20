# Methods to extend {ActiveRecord::ConnectionAdapters::PostgreSQLAdapter}
# to support database functions.
module PgSaurus::ConnectionAdapters::PostgreSQLAdapter::FunctionMethods
  # Regular expression used in function signature parsing:
  FUNCTION_PARSE_REGEXP = /^CREATE[\s\S]+FUNCTION /

  # Return +true+.
  def supports_functions?
    true
  end

  # Return a list of defined DB functions. Ignore function definitions that can't be parsed.
  def functions
    pg_major = ::PgSaurus::Engine.pg_server_version[0]
    res = select_all <<-SQL
      SELECT n.nspname AS "Schema",
        p.proname AS "Name",
        pg_catalog.pg_get_function_result(p.oid) AS "Returning",
       CASE
        WHEN #{pg_major >= 11 ? "p.prokind = 'w'" : "p.proiswindow"} THEN 'window'
        WHEN p.prorettype = 'pg_catalog.trigger'::pg_catalog.regtype  THEN 'trigger'
        ELSE 'normal'
       END   AS "Type",
       p.oid AS "Oid"
      FROM pg_catalog.pg_proc p
           LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
      WHERE pg_catalog.pg_function_is_visible(p.oid)
            AND n.nspname <> 'pg_catalog'
            AND n.nspname <> 'information_schema'
            AND #{pg_major >= 11 ? "p.prokind <> 'a'" : "p.proisagg <> TRUE"}
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
      volatility = parse_function_volatility(function_str)

      if definition
        buffer << ::PgSaurus::ConnectionAdapters::FunctionDefinition.new(name,
                                                                         returning,
                                                                         definition.strip,
                                                                         function_type,
                                                                         language,
                                                                         oid,
                                                                         volatility)
      end
      buffer
    end
  end

  # Create a new database function.
  def create_function(function_name, returning, definition, options = {})

    function_name = full_function_name(function_name, options)
    language      = options[:language] || 'plpgsql'
    replace       = if options[:replace] == false
                      ''
                    else
                      'OR REPLACE '
                    end
    volatility    = case options[:volatility]
                    when :volatile, :stable, :immutable
                      "\n  #{options[:volatility].to_s.upcase}"
                    else
                      ""
                    end

    sql = <<-SQL.gsub(/^[ ]{6}/, "")
      CREATE #{replace}FUNCTION #{function_name}
        RETURNS #{returning}
        LANGUAGE #{language}#{volatility}
      AS $function$
      #{definition.strip}
      $function$
    SQL

    execute(sql)
  end

  # Drop the given database function.
  def drop_function(function_name, options = {})
    function_name = full_function_name(function_name, options)

    execute "DROP FUNCTION #{function_name}"
  end

  # Retrieve the function name from the function SQL.
  def parse_function_name(function_str)
    function_str.
      split("\n").
      find { |line| line =~ FUNCTION_PARSE_REGEXP }.
      sub(FUNCTION_PARSE_REGEXP, '')
  end
  private :parse_function_name

  # Retrieve the function language from the function SQL.
  def parse_function_language(function_str)
    function_str.split("\n").find { |line| line =~ /LANGUAGE/ }.split(' ').last
  end
  private :parse_function_language

  # Retrieve the volatility of the function: volatile, stable, or immutable.
  # @return [Symbol]
  def parse_function_volatility(function_str)
    rows       = function_str.split("\n")
    lang_index = rows.index { |line| line =~ /LANGUAGE/ }
    def_index  = rows.index { |line| line =~ /AS \$function\$/ }

    if lang_index && def_index && def_index - lang_index == 2
      tokens = rows[def_index - 1].strip.downcase.split(" ")
      token  = tokens.find { |t| %w(volatile stable immutable).include? t }

      token.nil? ? :volatile : token.to_sym
    else
      :volatile
    end
  end
  private :parse_function_volatility

  # Retrieve the function definition from the function SQL.
  def parse_function_definition(function_str)
    function_str[/#{Regexp.escape("AS $function$\n")}(.*?)#{Regexp.escape("$function$")}/m, 1]
  end
  private :parse_function_definition

  # Write out the fully qualified function name if the :schema option is passed.
  def full_function_name(function_name, options)
    schema        = options[:schema]
    function_name = %Q{"#{schema}".#{function_name}} if schema
    function_name
  end
  private :full_function_name
end
