require 'spec_helper'

describe PgPower::ConnectionAdapters::PostgreSQLAdapter::ViewMethods do
  class PostgreSQLAdapter
    include ::PgPower::ConnectionAdapters::PostgreSQLAdapter::ViewMethods
  end

  let(:adapter_stub) { PostgreSQLAdapter.new }

  describe ".create_view" do
    it "refers to tools create_view" do
      expect(::PgPower::Tools).to receive(:create_view).with("someview", "")
      adapter_stub.create_view("someview", "")
    end
  end

  describe ".drop_view" do
    it "refers to tools drop_view" do
      expect(::PgPower::Tools).to receive(:drop_view).with("someview")
      adapter_stub.drop_view("someview")
    end
  end
end
