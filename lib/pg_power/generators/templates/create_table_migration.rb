<%# ref: activerecord-4.0.2/lib/rails/generators/active_record/migration/templates/create_table_migration.rb -%>
class <%= migration_class_name %> < ActiveRecord::Migration
  def change
    create_table :<%= table_name %> do |t|
<% attributes.each do |attribute| -%>
<% if attribute.password_digest? -%>
      t.string :password_digest<%= attribute.inject_options %>
<% else -%>
      t.<%= attribute.type %> :<%= attribute.name %><%= attribute.inject_options %>
<% end -%>
<% end -%>
<% if options[:timestamps] %>
      t.timestamps
<% end -%>
    end
<%# Create foreign key constraints for pg_power (or foreigner): -%>
<% attributes.select{|a| a.reference? }.each do |attribute| -%>
  add_foreign_key :<%= table_name %>, :<%= attribute.plural_name %>
<% end -%>
<%# Don't create redundant indices for foreign key constraints for pg_power (or foreigner): -%>
<% attributes_with_index.reject{|a| a.reference? }.each do |attribute| -%>
    add_index :<%= table_name %>, :<%= attribute.index_name %><%= attribute.inject_index_options %>
<% end -%>
  end
end
