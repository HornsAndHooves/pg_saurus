require 'spec_helper'

describe ActiveRecord::SchemaDumper do
  
  describe '.dump' do
    before(:all) do
      @stream = StringIO.new
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, @stream)
    end

    subject { @stream.string }

    it { should =~ /create_schema "demography"/ }
    it { should =~ /create_table "public.users"/ }
    it { should =~ /create_table "demography.citizens"/ }
    it { should =~ /create_table "demography.countries"/ }
  end
end
