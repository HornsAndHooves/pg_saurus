require 'spec_helper'

describe PgSaurus::Migration::CommandRecorder do
  class CommandRecorderStub
    include ::PgSaurus::Migration::CommandRecorder
  end

  let(:command_recorder_stub) { CommandRecorderStub.new }

  describe 'Triggers' do

    [ :create_trigger, :remove_trigger ].each do |method_name|
      it ".#{method_name}" do
        expect(command_recorder_stub).to receive(:record).with(method_name, [])
        command_recorder_stub.send(method_name)
      end
    end

    it '.invert_create_trigger' do
      expect(
        command_recorder_stub.invert_create_trigger(
                               ['pets', 'pets_not_empty', 'AFTER CREATE', {}]
        )
      ).to eq([:remove_trigger, ['pets', 'pets_not_empty', {}]])
    end

  end

  describe 'Functions' do

    [ :create_function, :drop_function ].each do |method_name|
      it ".#{method_name}" do
        expect(command_recorder_stub).to receive(:record).with(method_name, [])
        command_recorder_stub.send(method_name)
      end
    end

    it '.invert_create_functions' do
      expect(
        command_recorder_stub.invert_create_function(
          [ 'pets_not_empty()', :boolean, 'FU', { :schema => 'public' } ]
        )
      ).to eq([ :drop_function, [ "pets_not_empty()", { :schema => "public" } ] ])
    end

  end

  describe 'Comments' do
    [ :set_table_comment,
      :remove_table_comment,
      :set_column_comment,
      :set_column_comments,
      :remove_column_comment,
      :remove_column_comments,
      :set_index_comment,
      :remove_index_comment
    ].each{ |method_name|

      it ".#{method_name}" do
        expect(command_recorder_stub).to receive(:record).with(method_name, [])
        command_recorder_stub.send(method_name)
      end
    }

    it '.invert_set_table_comment' do
      command_recorder_stub.invert_set_table_comment([:foo, :bar]).
                            should == [:remove_table_comment, [:foo]]
    end

    it '.invert_set_column_comment' do
      command_recorder_stub.invert_set_column_comment([:foo, :bar, :baz]).
                            should == [:remove_column_comment, [:foo, :bar]]
    end

    it '.invert_set_column_comments' do
      command_recorder_stub.invert_set_column_comments([:foo, {:bar => :baz}]).
                            should == [:remove_column_comments, [:foo, :bar]]
    end

    it '.invert_set_index_comment' do
      command_recorder_stub.invert_set_index_comment([:foo, :bar]).
                            should == [:remove_index_comment, [:foo]]
    end
  end

end
