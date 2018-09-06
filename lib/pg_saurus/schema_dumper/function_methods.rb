# Support for dumping database functions.
module PgSaurus::SchemaDumper::FunctionMethods

  # :nodoc
  def tables_with_functions(stream)
    # Functions need to be dumped before tables.
    # Some indexes may use defined functions.
    dump_functions stream

    tables_without_functions(stream)

    stream
  end

  # Writes out a command to create each detected function.
  def dump_functions(stream)
    @connection.functions.each do |function|
      statement = "  create_function '#{function.name}', :#{function.returning}, <<-FUNCTION_DEFINITION.gsub(/^[\s]{4}/, ''), volatility: :#{function.volatility}"
      statement << "\n#{function.definition.split("\n").map{|line| "    #{line}" }.join("\n")}"
      statement << "\n  FUNCTION_DEFINITION\n\n"

      stream.puts statement
    end
  end

end
