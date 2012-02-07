class AddForeignKeys < ActiveRecord::Migration
  def up
    add_foreign_key 'demography.citizens', 'demography.countries'
    add_foreign_key 'demography.citizens', 'users'
  end

  def down
    remove_foreign_key 'demography.citizens', 'demography.countries'
    remove_foreign_key 'demography.citizens', 'users'
  end
end
