class CreateDemographyNationalities < ActiveRecord::Migration[5.2]
  def change
    create_table 'demography.nationalities' do |t|
      t.string :name
    end
  end
end
