require 'spec_helper'

describe PgPower::ConnectionAdapters::AbstractAdapter::SchemaMethods do
  let(:connection) { ActiveRecord::Base.connection }

  describe "#create_table_with_schema_option" do
    it "creates table with schema option" do
      connection.should_receive(:create_table_without_schema_option).
        with("demography.something", {}).and_call_original
      connection.create_table("something", schema: "demography")

      expect(connection.table_exists?("demography.something")).to be_true

      connection.drop_table("something", schema: "demography")
    end
  end

  describe "#drop_table_with_schema_option" do
    it "drops table with schema option" do
      connection.create_table("something", schema: "demography")
      expect(connection.table_exists?("demography.something")).to be_true

      connection.should_receive(:drop_table_without_schema_option).
        with("demography.something", {}).and_call_original
      connection.drop_table("something", schema: "demography")

      expect(connection.table_exists?("demography.something")).to be_false
    end
  end
end
