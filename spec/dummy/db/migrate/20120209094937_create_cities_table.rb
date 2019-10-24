class CreateCitiesTable < ActiveRecord::Migration[5.2]
  def change
    create_table 'demography.cities' do |t|
      t.integer :country_id
      t.integer :name
    end

    add_foreign_key "demography.cities", "demography.countries"
  end
end
