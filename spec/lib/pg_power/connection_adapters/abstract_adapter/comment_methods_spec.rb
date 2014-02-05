require 'spec_helper'

describe PgPower::ConnectionAdapters::AbstractAdapter::CommentMethods do
  class AbstractAdapter
    include ::PgPower::ConnectionAdapters::AbstractAdapter::CommentMethods
  end

  let(:adapter_stub) { AbstractAdapter.new }

  it ".supports_comments?" do
    expect(adapter_stub.supports_comments?).to be_false
  end
end
