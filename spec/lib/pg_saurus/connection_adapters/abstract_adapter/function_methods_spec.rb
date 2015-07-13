require 'spec_helper'

describe PgSaurus::ConnectionAdapters::AbstractAdapter::FunctionMethods do
  class AbstractAdapter
    include ::PgSaurus::ConnectionAdapters::AbstractAdapter::FunctionMethods
  end

  let(:adapter_stub) { AbstractAdapter.new }

  it ".supports_functions?" do
    expect(adapter_stub.supports_comments?).to be false
  end
end
