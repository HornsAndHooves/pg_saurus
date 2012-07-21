require 'spec_helper'

describe PgPower::Tools do
  describe '#move_table_to_schema' do
    it 'moves table to another schema' do
      Pet.create!(:name => "Flaaffy", :color => "#FFAABB")
      PgPower::Explorer.table_exists?('public.pets').should == true

      # Move table
      PgPower::Tools.move_table_to_schema :pets, :demography
      PgPower::Explorer.table_exists?('public.pets').should == false
      PgPower::Explorer.table_exists?('demography.pets').should == true

      # Move table back
      PgPower::Tools.move_table_to_schema 'demography.pets', :public
      PgPower::Explorer.table_exists?('public.pets').should == true
      PgPower::Explorer.table_exists?('demography.pets').should == false

      # Make sure data is not lost
      Pet.where(:name => "Flaaffy", :color => "#FFAABB").size.should == 1
    end
  end


  describe '#rename_constraint' do
    it 'renames constraint' do
      PgPower::Explorer.constraints_on_table('demography.people').should include 'people_citizen_id_fk'
      PgPower::Tools.rename_constraint('demography.people', 'people_citizen_id_fk', 'new_people_citizen_id_fk')

      PgPower::Explorer.constraints_on_table('demography.people').should_not include 'people_citizen_id_fk'
      PgPower::Explorer.constraints_on_table('demography.people').should include 'new_people_citizen_id_fk'

      # Rename back
      PgPower::Tools.rename_constraint('demography.people', 'new_people_citizen_id_fk', 'people_citizen_id_fk')

      PgPower::Explorer.constraints_on_table('demography.people').should include 'people_citizen_id_fk'
      PgPower::Explorer.constraints_on_table('demography.people').should_not include 'new_people_citizen_id_fk'
    end
  end
end
