require 'spec_helper'

describe PgPower::ConnectionAdapters::AbstractAdapter::IndexMethods do
  class AbstractAdapter
    include ::PgPower::ConnectionAdapters::AbstractAdapter::IndexMethods
  end

  let(:adapter_stub) { AbstractAdapter.new }

  it ".supports_partial_index?" do
    expect(adapter_stub.supports_partial_index?).to be_false
  end
end
