require 'spec_helper'

describe PgSaurus::Migration::CommandRecorder::SchemaMethods do
  class CommandRecorderStub
    include ::PgSaurus::Migration::CommandRecorder::SchemaMethods
  end

  let(:command_recorder_stub) { CommandRecorderStub.new }

  [:create_schema, :drop_schema, :move_table_to_schema].each do |method_name|
    it ".#{method_name}" do
      expect(command_recorder_stub).to receive(:record).with(method_name, [:foo, :bar])
      command_recorder_stub.send(method_name, :foo, :bar)
    end
  end

  it ".invert_create_schema" do
    expect(command_recorder_stub.invert_create_schema([:foo, :bar])).
      to eq([:drop_schema, [:foo]])
  end

  it ".invert_drop_schema" do
    expect(command_recorder_stub.invert_drop_schema([:foo, :bar])).
      to eq([:create_schema, [:foo]])
  end

  it ".invert_move_table_to_schema" do
    expect(command_recorder_stub.invert_move_table_to_schema(["sometable", "someschema"])).
      to eq([:move_table_to_schema, ["someschema.sometable", "public"]])
  end
end
