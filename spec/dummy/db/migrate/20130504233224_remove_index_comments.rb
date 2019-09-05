class RemoveIndexComments < ActiveRecord::Migration[5.2]
  def change
    remove_index_comment 'demography.index_demography_cities_on_country_id'
    remove_index_comment 'index_pets_on_breed_id'
  end
end
