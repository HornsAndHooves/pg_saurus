require 'spec_helper'

describe PgSaurus::ConnectionAdapters::Table::CommentMethods do
  class AbstractTable
    include ::PgSaurus::ConnectionAdapters::Table::CommentMethods

    def initialize
      @base       = Object.new
      @name = "sometable"
    end

  end

  let(:table_stub) { AbstractTable.new }
  let(:base)       { table_stub.instance_variable_get(:@base) }

  it ".set_table_comment" do
    expect(base).to receive(:set_table_comment).with("sometable", "somecomment")
    table_stub.set_table_comment("somecomment")
  end

  it ".remove_table_comment" do
    expect(base).to receive(:remove_table_comment).with("sometable")
    table_stub.remove_table_comment
  end

  it ".set_column_comment" do
    expect(base).to receive(:set_column_comment).with("sometable", "somecolumn", "somecomment")
    table_stub.set_column_comment("somecolumn", "somecomment")
  end

  it ".set_column_comments" do
    expect(base).
      to receive(:set_column_comments).
      with("sometable", "column1" => "comment1", "column2" => "comment2")
    table_stub.set_column_comments("column1" => "comment1", "column2" => "comment2")
  end

  it ".remove_column_comment" do
    expect(base).to receive(:remove_column_comment).with("sometable", "somecolumn")
    table_stub.remove_column_comment("somecolumn")
  end

  it ".remove_column_comments" do
    expect(base).to receive(:remove_column_comments).with("sometable", "column1", "column2")
    table_stub.remove_column_comments("column1", "column2")
  end
end
