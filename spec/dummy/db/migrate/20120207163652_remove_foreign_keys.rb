class RemoveForeignKeys < ActiveRecord::Migration
  def up
    remove_foreign_key 'demography.citizens', 'demography.countries'
    remove_foreign_key 'pets', 'demography.countries', :exclude_index => true
  end

  def down
    add_foreign_key 'demography.citizens', 'demography.countries'
    add_foreign_key 'pets', 'demography.countries'
  end
end
