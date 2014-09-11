require 'spec_helper'

describe PgSaurus::ConnectionAdapters::PostgreSQLAdapter::ViewMethods do
  class PostgreSQLAdapter
    include ::PgSaurus::ConnectionAdapters::PostgreSQLAdapter::ViewMethods
  end

  let(:adapter_stub) { PostgreSQLAdapter.new }

  describe ".create_view" do
    it "refers to tools create_view" do
      expect(::PgSaurus::Tools).to receive(:create_view).with("someview", "")
      adapter_stub.create_view("someview", "")
    end
  end

  describe ".drop_view" do
    it "refers to tools drop_view" do
      expect(::PgSaurus::Tools).to receive(:drop_view).with("someview")
      adapter_stub.drop_view("someview")
    end
  end
end
