class MovePeopleToDemographySchema < ActiveRecord::Migration[5.2]
  def change
    move_table_to_schema :people, :demography
  end
end
