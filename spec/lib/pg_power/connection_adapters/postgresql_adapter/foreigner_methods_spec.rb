require 'spec_helper'

describe PgPower::ConnectionAdapters::PostgreSQLAdapter::ForeignerMethods do
  class PostgreSQLAdapter
    include ::PgPower::ConnectionAdapters::PostgreSQLAdapter::ForeignerMethods
  end

  let(:adapter_stub) { PostgreSQLAdapter.new }

  it ".supports_foreign_keys?" do
    expect(adapter_stub.supports_foreign_keys?).to be_true
  end

  describe ".foreign_key_name" do
    it "returns options[:name] if presents" do
      expect(adapter_stub.send(:foreign_key_name, "sometable", "comecolumn", name: "somename")).to eq "somename"
    end
  end

  it ".dependency_sql" do
    expect(adapter_stub.send(:dependency_sql, :nullify)).to   eq "ON DELETE SET NULL"
    expect(adapter_stub.send(:dependency_sql, :delete)).to    eq "ON DELETE CASCADE"
    expect(adapter_stub.send(:dependency_sql, :restrict)).to  eq "ON DELETE RESTRICT"
    expect(adapter_stub.send(:dependency_sql, :something)).to eq ""
  end
end
