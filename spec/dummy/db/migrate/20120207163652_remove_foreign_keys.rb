class RemoveForeignKeys < ActiveRecord::Migration
  def up
    remove_foreign_key 'demography.citizens', 'demography.countries'
  end

  def down
    add_foreign_key 'demography.citizens', 'demography.countries'
  end
end
