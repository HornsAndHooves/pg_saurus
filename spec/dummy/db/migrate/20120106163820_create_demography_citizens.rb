class CreateDemographyCitizens < ActiveRecord::Migration
  def change
    create_table 'demography.citizens' do |t|
      t.integer :country_id
      t.integer :user_id

      t.timestamps
    end
  end
end
