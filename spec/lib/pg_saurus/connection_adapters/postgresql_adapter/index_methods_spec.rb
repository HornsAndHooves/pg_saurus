require 'spec_helper'

describe PgSaurus::ConnectionAdapters::PostgreSQLAdapter::IndexMethods do
  class PostgreSQLAdapter
    include ::PgSaurus::ConnectionAdapters::PostgreSQLAdapter::IndexMethods
  end

  let(:adapter_stub) { PostgreSQLAdapter.new }

  it ".supports_partial_index?" do
    expect(adapter_stub.supports_partial_index?).to be true
  end
end
