class CreateDemographyNationalities < ActiveRecord::Migration
  def change
    create_table 'demography.nationalities' do |t|
      t.string :name
    end
  end
end
