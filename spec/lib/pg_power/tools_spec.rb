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
end