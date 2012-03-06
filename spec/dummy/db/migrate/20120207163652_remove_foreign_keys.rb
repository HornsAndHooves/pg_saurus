class RemoveForeignKeys < ActiveRecord::Migration
  def up
    remove_foreign_key 'demography.citizens', 'demography.countries'
    remove_foreign_key 'pets', 'demography.countries', :exclude_index => true
    #remove_foreign_key 'pets', 'owners'
    remove_foreign_key 'pets', :name => "pets_owner_id_fk"
    remove_foreign_key 'pets', :name => "pets_breed_id_fk", :exclude_index => true
  end

  def down
    add_foreign_key 'demography.citizens', 'demography.countries'
    add_foreign_key 'pets', 'demography.countries'
    add_foreign_key 'pets', 'owners'
  end
end
