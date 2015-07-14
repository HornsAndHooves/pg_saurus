require "spec_helper"

describe PgSaurus::ConnectionAdapters::PostgreSQLAdapter::SchemaMethods do
  class PostgreSQLAdapter
    include ::PgSaurus::ConnectionAdapters::PostgreSQLAdapter::SchemaMethods
  end

  let(:adapter_stub) { PostgreSQLAdapter.new }

  describe ".create_schema" do
    it "refers to tools create_schema" do
      expect(::PgSaurus::Tools).to receive(:create_schema).with("someschema")
      adapter_stub.create_schema("someschema")
    end
  end

  describe ".create_schema_if_not_exists" do
    it "refers to tools create_schema" do
      expect(::PgSaurus::Tools).to receive(:create_schema).with("someschema")
      adapter_stub.create_schema("someschema")
    end

    it "doesn't create the schema if it already exists" do
      PgSaurus::Tools.create_schema "aschema"
      expect(::PgSaurus::Tools).not_to receive(:create_schema).with("aschema")
      adapter_stub.create_schema_if_not_exists("aschema")
    end
  end

  describe ".drop_schema" do
    it "refers to tools drop_schema" do
      expect(::PgSaurus::Tools).to receive(:drop_schema).with("someschema")
      adapter_stub.drop_schema("someschema")
    end
  end

  describe ".drop_schema_if_exists" do
    it "refers to tools drop_schema" do
      PgSaurus::Tools.create_schema "someschema"
      expect(::PgSaurus::Tools).to receive(:drop_schema).with("someschema")
      adapter_stub.drop_schema_if_exists("someschema")
    end

    it "doesn't try to drop a non-existent schema" do
      expect(::PgSaurus::Tools).not_to receive(:drop_schema).with("someotherschema")
      adapter_stub.drop_schema_if_exists("someotherschema")
    end
  end

  describe ".move_table_to_schema" do
    it "refers to tools move_table_to_schema" do
      expect(::PgSaurus::Tools).to receive(:move_table_to_schema).with("sometable", "someschema")
      adapter_stub.move_table_to_schema("sometable", "someschema")
    end
  end
end
