class RemoveForeignKeys < ActiveRecord::Migration
  def up
    remove_foreign_key 'demography.citizens', column: :country_id, remove_index: true
    remove_foreign_key 'pets', 'demography.countries'
    #remove_foreign_key 'pets', 'owners'
    remove_foreign_key 'pets', :column => "owner_id", remove_index: true
    remove_foreign_key 'pets', :column => "breed_id"
  end

  def down
    add_foreign_key 'demography.citizens', 'demography.countries'
    add_foreign_key 'pets', 'demography.countries'
    add_foreign_key 'pets', 'owners'
  end
end
