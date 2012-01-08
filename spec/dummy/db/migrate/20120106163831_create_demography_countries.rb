class CreateDemographyCountries < ActiveRecord::Migration
  def change
    create_table 'demography.countries' do |t|
      t.string :name

      t.timestamps
    end
  end
end
