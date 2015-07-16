require 'spec_helper'

describe PgSaurus::ConnectionAdapters::AbstractAdapter::IndexMethods do
  class AbstractAdapter
    include ::PgSaurus::ConnectionAdapters::AbstractAdapter::IndexMethods
  end

  let(:adapter_stub) { AbstractAdapter.new }

  it ".supports_partial_index?" do
    expect(adapter_stub.supports_partial_index?).to be false
  end
end
