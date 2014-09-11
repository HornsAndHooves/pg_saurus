# Extends ActiveRecord::SchemaDumper class to dump views
module PgSaurus::SchemaDumper::ViewMethods
  # Dump create view statements
  def tables_with_views(stream)
    tables_without_views(stream)
    views(stream)
    stream
  end

  # Generates code to create views.
  def views(stream)
    # Don't create "system" views.
    view_names = PgSaurus::Tools.views
    view_names.each do |options|
      write_view_definition(stream,
                            options["table_schema"],
                            options["table_name"],
                            options["view_definition"])
    end
    stream << "\n"
  end
  private :views

  # Generates code to create view.
  def write_view_definition(stream, table_schema, table_name, view_definition)
    stream << "  create_view \"#{table_schema}.#{table_name}\", <<-SQL\n" \
              "    #{view_definition}\n" \
              "  SQL\n"
  end
  private :write_view_definition

end
