class AddIndexComments < ActiveRecord::Migration
  def change
    set_index_comment 'demography.index_demography_citizens_on_country_id_and_user_id', 'Unique index on active citizens'
    set_index_comment 'demography.index_demography_cities_on_country_id', 'Index on country id'
    set_index_comment 'index_pets_on_breed_id', 'Index on breed_id'
    set_index_comment 'index_pets_on_to_tsvector_name_gist', 'Functional index on name'
  end
end
