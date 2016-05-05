require "spec_helper"

describe PgSaurus::ConnectionAdapters::AbstractAdapter::SchemaMethods do
  let(:connection) { ActiveRecord::Base.connection }

  describe "#create_table_with_schema_option" do
    it "creates table with schema option" do
      expect(connection).to receive(:create_table_without_schema_option).
        with("demography.something", {}).and_call_original

      connection.create_table("something", schema: "demography")

      expect(connection.table_exists?("demography.something")).to be true

      connection.drop_table("something", schema: "demography")
    end

    it "allows options to be a frozen Hash" do
      options = { schema: "demography" }.freeze
      expect { connection.create_table("something", options) }.not_to raise_error
    end
  end

  describe "#drop_table_with_schema_option" do
    it "drops table with schema option" do
      connection.create_table("something", schema: "demography")
      expect(connection.table_exists?("demography.something")).to be true

      connection.drop_table("something", schema: "demography")

      expect(connection.table_exists?("demography.something")).to be false
    end

    it "allows options to be a frozen Hash" do
      options = { schema: "demography" }.freeze
      connection.create_table("something", options)

      expect { connection.drop_table("something", options) }.not_to raise_error
    end
  end
end
