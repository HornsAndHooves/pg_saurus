class AddForeignKeys < ActiveRecord::Migration
  def change
    add_foreign_key 'pets', 'users'
    add_foreign_key 'demography.citizens', 'demography.countries'
    add_foreign_key 'demography.citizens', 'users'
  end
end
