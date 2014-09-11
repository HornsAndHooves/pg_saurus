require 'spec_helper'

describe PgSaurus::ConnectionAdapters::AbstractAdapter::CommentMethods do
  class AbstractAdapter
    include ::PgSaurus::ConnectionAdapters::AbstractAdapter::CommentMethods
  end

  let(:adapter_stub) { AbstractAdapter.new }

  it ".supports_comments?" do
    expect(adapter_stub.supports_comments?).to be false
  end
end
