require 'spec_helper'

describe 'Indexes' do
  describe '#add_index' do
    it 'should be built with the :where option' do
      index_options = {:where => 'active'}
      PgPower::Explorer.index_exists?('demography.citizens', [:country_id, :user_id], index_options).should == true
    end
  end

  describe '#index_exists' do
    it 'should be true for a valid :where option' do
      index_options = {:where => 'active'}
      PgPower::Explorer.index_exists?('demography.citizens', [:country_id, :user_id], index_options).should == true
    end

    it 'should be false for an invalid :where option' do
      index_options = {:where => 'active'}
      PgPower::Explorer.index_exists?('demography.citizens', [:country_id], index_options).should == false
    end
  end
end
