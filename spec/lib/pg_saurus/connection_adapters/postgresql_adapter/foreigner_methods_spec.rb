require 'spec_helper'

describe PgSaurus::ConnectionAdapters::PostgreSQLAdapter::ForeignKeyMethods do
  class PostgreSQLAdapter
    include ::PgSaurus::ConnectionAdapters::PostgreSQLAdapter::ForeignKeyMethods
  end

  let(:adapter_stub) { PostgreSQLAdapter.new }

  describe ".drop_table" do
    it "disables referential integrity if options :force" do
      expect(adapter_stub).to receive(:disable_referential_integrity)
      adapter_stub.drop_table(force: true)
    end
  end

end
