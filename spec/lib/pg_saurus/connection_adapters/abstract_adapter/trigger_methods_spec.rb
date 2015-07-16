require "spec_helper"

describe PgSaurus::ConnectionAdapters::AbstractAdapter::TriggerMethods do
  class AbstractAdapter
    include ::PgSaurus::ConnectionAdapters::AbstractAdapter::TriggerMethods
  end

  let(:adapter_stub) { AbstractAdapter.new }

  it ".supports_functions?" do
    expect(adapter_stub.supports_triggers?).to be false
  end
end
