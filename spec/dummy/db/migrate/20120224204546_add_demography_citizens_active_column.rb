class AddDemographyCitizensActiveColumn < ActiveRecord::Migration
  def change
    add_column 'demography.citizens', :active, :boolean, null: false, default: false

    add_index 'demography.citizens', [:country_id, :user_id], unique: true, where: 'active'
  end
end
