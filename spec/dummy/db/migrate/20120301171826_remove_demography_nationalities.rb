class RemoveDemographyNationalities < ActiveRecord::Migration[5.2]
  def change
    drop_table 'nationalities', :schema => 'demography'
  end
end
