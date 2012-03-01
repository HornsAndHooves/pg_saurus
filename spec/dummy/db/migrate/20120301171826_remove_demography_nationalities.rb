class RemoveDemographyNationalities < ActiveRecord::Migration
  def change
    drop_table 'nationalities', :schema => 'demography'
  end
end
