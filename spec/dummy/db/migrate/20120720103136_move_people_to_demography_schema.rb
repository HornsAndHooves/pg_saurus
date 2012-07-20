class MovePeopleToDemographySchema < ActiveRecord::Migration
  def change
    move_table_to_schema :people, :demography
  end
end
