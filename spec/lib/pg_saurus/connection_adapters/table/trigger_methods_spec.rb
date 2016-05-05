require "spec_helper"

describe PgSaurus::ConnectionAdapters::Table::TriggerMethods do
  class AbstractTable
    include ::PgSaurus::ConnectionAdapters::Table::TriggerMethods

    def initialize
      @base = Object.new
      @name = "sometable"
    end

  end

  let(:table_stub) { AbstractTable.new }
  let(:base)       { table_stub.instance_variable_get(:@base) }

  specify ".create_trigger" do
    expect(base).to receive(:create_trigger).with("sometable", "proc_name", "event", {})

    table_stub.create_trigger "proc_name", "event"
  end

  specify ".remove_trigger" do
    expect(base).to receive(:remove_trigger).with("sometable", "proc_name", {})

    table_stub.remove_trigger "proc_name"
  end

end
