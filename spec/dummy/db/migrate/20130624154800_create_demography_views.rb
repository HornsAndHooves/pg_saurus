class CreateDemographyViews < ActiveRecord::Migration[5.2]
  def change
    create_view "demography.citizens_view", "select * from demography.citizens"
  end
end
