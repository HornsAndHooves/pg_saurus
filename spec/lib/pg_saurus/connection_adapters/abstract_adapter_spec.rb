require 'spec_helper'

describe PgSaurus::ConnectionAdapters::AbstractAdapter do
  class AbstractAdapterStub
    def self.alias_method_chain(*args)
    end

    include ::PgSaurus::ConnectionAdapters::AbstractAdapter
  end

  let(:adapter_stub){ AbstractAdapterStub.new }

  it 'should define method stubs for comment methods' do
    [ :set_table_comment,
      :set_column_comment,
      :set_column_comments,
      :remove_table_comment,
      :remove_column_comment,
      :remove_column_comments,
      :set_index_comment,
      :remove_index_comment
    ].each { |method_name| adapter_stub.respond_to?(method_name).should be true }
  end
end
