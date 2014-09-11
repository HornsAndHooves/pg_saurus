require 'spec_helper'

describe PgSaurus::ConnectionAdapters::PostgreSQLAdapter::IndexMethods do
  class PostgreSQLAdapter
    include ::PgSaurus::ConnectionAdapters::PostgreSQLAdapter::IndexMethods
  end

  let(:adapter_stub) { PostgreSQLAdapter.new }

  it ".supports_partial_index?" do
    expect(adapter_stub.supports_partial_index?).to be true
  end

  describe "#index_name_for_remove" do
    let(:connection) { ActiveRecord::Base.connection }

    it "refers to origin if no schema is given" do
      expect(connection.index_name_for_remove("users", column: :email)).
        to eq("index_users_on_email")
    end

    it "takes schema into account" do
      expect(connection.index_name_for_remove("demography.cities", column: :country_id)).
        to eq("demography.index_demography_cities_on_country_id")
    end
  end
end
