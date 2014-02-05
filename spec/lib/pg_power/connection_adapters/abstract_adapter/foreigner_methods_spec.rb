require 'spec_helper'

describe PgPower::ConnectionAdapters::AbstractAdapter::ForeignerMethods do
  class AbstractAdapter
    include ::PgPower::ConnectionAdapters::AbstractAdapter::ForeignerMethods
  end

  let(:adapter_stub) { AbstractAdapter.new }

  it ".supports_foreign_keys?" do
    expect(adapter_stub.supports_foreign_keys?).to be_false
  end

  it ".foreign_keys" do
    expect(adapter_stub.foreign_keys(nil)).to eq([])
  end
end
