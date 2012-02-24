class CreateCitiesTable < ActiveRecord::Migration
  def change
    create_table 'demography.cities' do |t|
      t.integer :country_id
      t.integer :name
    end

    add_foreign_key "demography.cities", "demography.countries", :exclude_index => true
  end
end
