class DemographyPopulationStatistics < ActiveRecord::Migration
  def change
    create_table "population_statistics", :schema => "demography" do |t|
      t.integer :year
      t.integer :population
    end
  end
end
