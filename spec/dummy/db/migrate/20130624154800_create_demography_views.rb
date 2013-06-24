class CreateDemographyViews < ActiveRecord::Migration
  def change
    create_view "demography.citizens_view", "select * from demography.citizens"
  end
end
