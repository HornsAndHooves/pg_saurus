class DemographyPopulationStatistics < ActiveRecord::Migration[5.2]
  def change
    create_table "population_statistics", schema: "demography" do |t|
      t.integer :year
      t.integer :population
    end
  end
end
