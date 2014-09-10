require 'spec_helper'

describe PgPower::ConnectionAdapters::PostgreSQLAdapter::SchemaMethods do
  class PostgreSQLAdapter
    include ::PgPower::ConnectionAdapters::PostgreSQLAdapter::SchemaMethods
  end

  let(:adapter_stub) { PostgreSQLAdapter.new }

  describe ".create_schema" do
    it "refers to tools create_schema" do
      expect(::PgPower::Tools).to receive(:create_schema).with("someschema")
      adapter_stub.create_schema("someschema")
    end
  end

  describe ".drop_schema" do
    it "refers to tools drop_schema" do
      expect(::PgPower::Tools).to receive(:drop_schema).with("someschema")
      adapter_stub.drop_schema("someschema")
    end
  end

  describe ".move_table_to_schema" do
    it "refers to tools move_table_to_schema" do
      expect(::PgPower::Tools).to receive(:move_table_to_schema).with("sometable", "someschema")
      adapter_stub.move_table_to_schema("sometable", "someschema")
    end
  end
end
