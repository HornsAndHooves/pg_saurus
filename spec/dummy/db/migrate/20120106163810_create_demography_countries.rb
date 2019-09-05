class CreateDemographyCountries < ActiveRecord::Migration[5.2]
  def change
    create_table 'demography.countries' do |t|
      t.string :name
      t.string :continent

      t.timestamps
    end

    set_table_comment 'demography.countries', "Countries"

    set_column_comments 'demography.countries',
      :name => "Country name",
      :continent => "Continent"
  end
end
