class RemoveCommentsOnCountriesTable < ActiveRecord::Migration
  def up
    remove_table_comment 'demography.countries'
    remove_column_comment 'demography.countries', :continent
  end

  def down
    set_table_comment 'demography.countries', "Countries"
  end
end
