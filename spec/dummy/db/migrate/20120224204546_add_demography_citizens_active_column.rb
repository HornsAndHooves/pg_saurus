class AddDemographyCitizensActiveColumn < ActiveRecord::Migration
  def change
    add_column 'demography.citizens', :active, :boolean, :null => false, :default => false

    add_index 'demography.citizens', [:country_id, :user_id], :name => 'index_demography_citizens_on_country_id_and_user_id_and_active',
                                                              :unique => true,
                                                              :where => 'active'
  end
end
