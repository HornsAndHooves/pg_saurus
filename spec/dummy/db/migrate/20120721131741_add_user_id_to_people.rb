class AddUserIdToPeople < ActiveRecord::Migration
  def change
    add_column 'demography.people', :citizen_id, :integer
    add_foreign_key 'demography.people', 'demography.citizens', :name => 'people_citizen_id_fk'
  end
end
