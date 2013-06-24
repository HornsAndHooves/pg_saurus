# Extends ActiveRecord::SchemaDumper class to dump views
module PgPower::SchemaDumper::ViewMethods
  # Dump create view statements
  def header_with_views(stream)
    header_without_views(stream)
    views(stream)
    stream
  end
  
  # Generates code to create views.
  def views(stream)
    # Don't create "system" views.
    view_names = PgPower::Tools.views
    view_names.each do |view_name, view_definition|
      view(view_name, view_definition, stream)
    end
    stream << "\n"
  end
  private :views

  # Generates code to create view.
  def view(view_name, view_definition, stream)
    stream << "  create_view \"#{view_name}\", \"#{view_definition}\"\n"
  end
  private :view

end
