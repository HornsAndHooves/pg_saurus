require "spec_helper"

describe PgSaurus::ConnectionAdapters::PostgreSQLAdapter::TriggerMethods do

  let(:connection) { ActiveRecord::Base.connection }

  it ".supports_triggers?" do
    expect(connection.supports_triggers?).to be true
  end

  context ".create_trigger" do

    it "executes a query to create a trigger" do
      sql = <<-SQL.gsub(/^[ ]{8}/, "")
        CREATE CONSTRAINT TRIGGER trigger_pets_not_empty_trigger_proc
          AFTER INSERT
          ON "public"."pets"
          DEFERRABLE INITIALLY DEFERRED
          FOR EACH ROW
          WHEN (name = 'Fluffy')
          EXECUTE PROCEDURE pets_not_empty_trigger_proc()
      SQL

      expect(connection).to receive(:execute).with(sql.strip)

      connection.create_trigger :pets,
                     :pets_not_empty_trigger_proc,
                     "AFTER INSERT",
                     for_each:           "ROW",
                     schema:             "public",
                     constraint:         true,
                     deferrable:         true,
                     initially_deferred: true,
                     condition:          "name = 'Fluffy'"
    end

  end

  context ".remove_trigger" do

    it "derives the trigger name" do
      expect(connection).to receive(:execute).with('DROP TRIGGER trigger_foo_bar ON "pets"')

      connection.remove_trigger :pets, "foo_bar()"
    end

    it "accepts an explicitly named trigger" do
      expect(connection).to receive(:execute).with('DROP TRIGGER trigger_foo_bar ON "pets"')

      connection.remove_trigger :pets, "foo_bar_baz", name: "trigger_foo_bar"
    end

  end
end
