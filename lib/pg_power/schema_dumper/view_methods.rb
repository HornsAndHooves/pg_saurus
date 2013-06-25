# Extends ActiveRecord::SchemaDumper class to dump views
module PgPower::SchemaDumper::ViewMethods
  # Dump create view statements
  def tables_with_views(stream)
    tables_without_views(stream)
    views(stream)
    stream
  end
  
  # Generates code to create views.
  def views(stream)
    # Don't create "system" views.
    view_names = PgPower::Tools.views
    view_names.each do |options|
      view(options["table_schema"], options["table_name"], options["view_definition"], stream)
    end
    stream << "\n"
  end
  private :views

  # Generates code to create view.
  def view(table_schema, table_name, view_definition, stream)
    stream << "  create_view \"#{table_schema}.#{table_name}\", \"#{view_definition}\"\n"
  end
  private :view

end
