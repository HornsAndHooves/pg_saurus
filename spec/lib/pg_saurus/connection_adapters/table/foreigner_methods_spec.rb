require 'spec_helper'

describe PgSaurus::ConnectionAdapters::Table::ForeignerMethods do
  class AbstractTable
    include ::PgSaurus::ConnectionAdapters::Table::ForeignerMethods

    def initialize
      @base       = Object.new
      @table_name = "sometable"
    end

    def references_without_foreign_keys(*args)
      true
    end
  end

  let(:table_stub) { AbstractTable.new }
  let(:base)       { table_stub.instance_variable_get(:@base) }

  it ".foreign_key" do
    expect(base).to receive(:add_foreign_key).with("sometable", "someothertable", {})
    table_stub.foreign_key("someothertable", {})
  end

  it ".remove_foreign_key" do
    expect(base).to receive(:remove_foreign_key).with("sometable", {})
    table_stub.remove_foreign_key({})
  end

  it ".references_with_foreign_keys" do
    caller = double("caller").as_null_object.tap do |c|
      allow(c).to receive(:[]).and_return([])
    end
    allow(table_stub).to receive(:caller).and_return(caller)

    expect(ActiveSupport::Deprecation).to receive(:send).
      with(:deprecation_message,
           caller,
           ":foreign_key in t.references is deprecated. Use t.foreign_key instead")

    expect(table_stub).to receive(:references_without_foreign_keys)
    table_stub.references_with_foreign_keys(foreign_key: "someforeignkey")
  end
end
