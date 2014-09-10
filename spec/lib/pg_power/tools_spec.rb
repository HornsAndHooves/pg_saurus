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

  let(:connection) { PgPower::Tools.send(:connection) }

  it ".create_schema" do
    expect(connection).to receive(:execute).with(%{CREATE SCHEMA "someschema"})
    PgPower::Tools.create_schema("someschema")
  end

  it ".drop_schema" do
    expect(connection).to receive(:execute).with(%{DROP SCHEMA "someschema"})
    PgPower::Tools.drop_schema("someschema")
  end

  it ".create_view" do
    expect(connection).to receive(:execute).with("CREATE VIEW someview AS SELECT 1")
    PgPower::Tools.create_view("someview", "SELECT 1")
  end

  it ".drop_view" do
    expect(connection).to receive(:execute).with("DROP VIEW someview")
    PgPower::Tools.drop_view("someview")
  end

  it ".schemas" do
    expect(PgPower::Tools.schemas).to include("demography")
  end

  it ".views" do
    PgPower::Tools.create_view("someview", "SELECT 1")

    result = PgPower::Tools.views.to_a.find do |view|
      view['table_schema'] == "public" && view['table_name'] == "someview"
    end

    expect(result).not_to be_nil
    expect(result['view_definition']).to match(/SELECT 1;/)

    PgPower::Tools.drop_view("someview")
  end
end
