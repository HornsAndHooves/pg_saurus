<%# ref: activerecord-4.0.2/lib/rails/generators/active_record/migration/templates/migration.rb -%>
class <%= migration_class_name %> < ActiveRecord::Migration
<%- if migration_action == 'add' -%>
  def change
<% attributes.each do |attribute| -%>
  <%- if attribute.reference? -%>
    <%-# Use foreign key constraints for pg_power (or foreigner), instead. Caveat: polymorphic associations can't be created via generators.: -%>
    <%-# add_reference :<%= table_name % >, :<%= attribute.name % ><%= attribute.inject_options % > -%>
    <%-# Create foreign key constraints for pg_power (or foreigner): -%>
    add_foreign_key :<%= table_name %>, :<%= attribute.plural_name %><%= attribute.inject_options %>
  <%- else -%>
    add_column :<%= table_name %>, :<%= attribute.name %>, :<%= attribute.type %><%= attribute.inject_options %>
    <%- if attribute.has_index? -%>
    add_index :<%= table_name %>, :<%= attribute.index_name %><%= attribute.inject_index_options %>
    <%- end -%>
  <%- end -%>
<%- end -%>
  end
<%- elsif migration_action == 'join' -%>
  def change
    create_join_table :<%= join_tables.first %>, :<%= join_tables.second %> do |t|
    <%- attributes.each do |attribute| -%>
      <%= '# ' unless attribute.has_index? -%>t.index <%= attribute.index_name %><%= attribute.inject_index_options %>
    <%- end -%>
    end
  end
<%- else -%>
  def change
<% attributes.each do |attribute| -%>
<%- if migration_action -%>
  <%- if attribute.reference? -%>
    <%-# Use foreign key constraints for pg_power (or foreigner), instead. Caveat: polymorphic associations can't be created via generators.: -%>
    <%-# remove_reference :<%= table_name % >, :<%= attribute.name % ><%= attribute.inject_options % > -%>
    <%-# Remove foreign key constraints for pg_power (or foreigner): -%>
    remove_foreign_key :<%= table_name %>, :<%= attribute.plural_name %><%= attribute.inject_options %>
  <%- else -%>
    <%- if attribute.has_index? -%>
    remove_index :<%= table_name %>, :<%= attribute.index_name %><%= attribute.inject_index_options %>
    <%- end -%>
    remove_column :<%= table_name %>, :<%= attribute.name %>, :<%= attribute.type %><%= attribute.inject_options %>
  <%- end -%>
<%- end -%>
<%- end -%>
  end
<%- end -%>
end
