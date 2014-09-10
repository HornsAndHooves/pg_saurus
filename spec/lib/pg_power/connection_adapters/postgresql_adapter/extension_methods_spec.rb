require 'spec_helper'

describe PgPower::ConnectionAdapters::PostgreSQLAdapter::ExtensionMethods do
  class PostgreSQLAdapter
    include ::PgPower::ConnectionAdapters::PostgreSQLAdapter::ExtensionMethods
  end

  let(:adapter_stub) { PostgreSQLAdapter.new }

  it ".supports_extensions?" do
    expect(adapter_stub.supports_extensions?).to be true
  end

  it ".create_extension" do
    expect(adapter_stub).to receive(:execute).with(/CREATE EXTENSION(.+)\"someextension\"(.?)/)

    adapter_stub.create_extension("someextension", {})
  end

  describe ".drop_extension" do
    it "raises ArgumentError on invalid mode" do
      expect(adapter_stub).to receive(:execute).with(/DROP EXTENSION(.+)\"someextension\"(.?)/)

      adapter_stub.drop_extension("someextension", {})
    end

    it ".drop_extension" do
      expect {
        adapter_stub.drop_extension("someextension", {mode: :invalidmode})
      }.to raise_error(ArgumentError, /Expected one of/)
    end
  end
end
