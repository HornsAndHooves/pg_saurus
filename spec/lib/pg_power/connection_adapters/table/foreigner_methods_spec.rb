require 'spec_helper'

describe PgPower::ConnectionAdapters::Table::ForeignerMethods do
  class AbstractTable
    include ::PgPower::ConnectionAdapters::Table::ForeignerMethods

    def initialize
      @base = Object.new
      @table_name = "sometable"
    end

    def references_without_foreign_keys(*args)
      true
    end
  end

  let(:table_stub) { AbstractTable.new }
  let(:base)       { table_stub.instance_variable_get(:@base) }

  it ".foreign_key" do
    base.should_receive(:add_foreign_key).with("sometable", "someothertable", {})
    table_stub.foreign_key("someothertable", {})
  end

  it ".remove_foreign_key" do
    base.should_receive(:remove_foreign_key).with("sometable", {})
    table_stub.remove_foreign_key({})
  end

  it ".references_with_foreign_keys" do
    caller = double("caller").as_null_object.tap { |c| c.stub(:[]).and_return([]) }
    table_stub.stub(:caller).and_return(caller)

    ActiveSupport::Deprecation.should_receive(:send).with(:deprecation_message, caller,
                                                          ":foreign_key in t.references is deprecated. " \
                                                          "Use t.foreign_key instead")

    table_stub.should_receive(:references_without_foreign_keys)
    table_stub.references_with_foreign_keys(foreign_key: "someforeignkey")
  end
end
