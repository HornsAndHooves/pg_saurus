require 'spec_helper'

describe PgSaurus::Migration::CommandRecorder::ViewMethods do
  class CommandRecorderStub
    include ::PgSaurus::Migration::CommandRecorder::ViewMethods
  end

  let(:command_recorder_stub) { CommandRecorderStub.new }

  [:create_view, :drop_view].each do |method_name|
    it ".#{method_name}" do
      expect(command_recorder_stub).to receive(:record).with(method_name, [:foo, :bar])
      command_recorder_stub.send(method_name, :foo, :bar)
    end
  end

  it ".invert_create_view" do
    expect(command_recorder_stub.invert_create_view([:foo, :bar])).
      to eq([:drop_view, [:foo]])
  end
end
