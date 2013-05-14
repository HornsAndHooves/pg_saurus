require 'spec_helper'

describe PgPower::ConnectionAdapters::AbstractAdapter do
  class AbstractAdapterStub
    def self.alias_method_chain(*args)
    end

    include ::PgPower::ConnectionAdapters::AbstractAdapter
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
      :remove_index_comment ].each { |method_name| adapter_stub.respond_to?(method_name).should be_true }
  end

  it 'should define method stubs for foreign key methods' do
    [ :add_foreign_key,
      :remove_foreign_key ].each { |method_name| adapter_stub.respond_to?(method_name).should be_true }
  end
end