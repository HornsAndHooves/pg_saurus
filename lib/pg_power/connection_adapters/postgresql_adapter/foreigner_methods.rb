# Obtains {#add_foreign_key} and {#remove_foreign_key} methods provided by 
# foreigner gem to correctly calculate column name when table with schema
# prefix is passed.
module PgPower::ConnectionAdapters::PostgreSQLAdapter::ForeignerMethods
  # Forces {#add_foreign_key} to use :column option calculated from
  # table name if it was not passed explicitly.
  def add_foreign_key_sql_with_column(from_table, to_table, options = {})
    column = "#{to_table.to_s.split('.').last.singularize}_id"
    options[:column] ||= column
    add_foreign_key_sql_without_column(from_table, to_table, options)
  end


  # Forces {#remove_foreign_key} to use :column option calculated from
  # table name if it was not passed explicitly.
  def remove_foreign_key_sql_with_column(table, options_or_table)
    if Hash === options_or_table
      options = options_or_table
    else
      column = "#{options_or_table.to_s.split('.').last.singularize}_id"
      options = {:column => column}
    end
    remove_foreign_key_sql_without_column(table, options)
  end
end
