require 'spec_helper'

describe PgSaurus::ConnectionAdapters::PostgreSQLAdapter::CommentMethods do
  class PostgreSQLAdapter
    include ::PgSaurus::ConnectionAdapters::PostgreSQLAdapter::CommentMethods
  end

  context "stubbed object" do
    let(:adapter_stub) { PostgreSQLAdapter.new }

    it ".supports_comments?" do
      expect(adapter_stub.supports_comments?).to be true
    end
  end

  context "connection object" do
    let(:connection)   { ActiveRecord::Base.connection }

    it "#set_table_comment" do
      expect(connection).to receive(:execute).
        with("COMMENT ON TABLE \"users\" IS $$Users list$$;")

      connection.set_table_comment("users", "Users list")
    end

    it "#set_column_comment" do
      expect(connection).to receive(:execute).
        with("COMMENT ON COLUMN \"users\".\"name\" IS $$User name$$;")
      connection.set_column_comment("users", "name", "User name")
    end

    it "#set_column_comments" do
      expect(connection).to receive(:set_column_comment).
        with("users", "name", "User name")
      expect(connection).to receive(:set_column_comment).
        with("users", "email", "User email")

      connection.set_column_comments("users", {'name' =>  "User name", 'email' => "User email"})
    end

    it "#set_index_comment" do
      expect(connection).to receive(:execute).
        with("COMMENT ON INDEX index_users_on_email IS $$Index on user email$$;")

      connection.set_index_comment("index_users_on_email", "Index on user email")
    end

    it "#remove_table_comment" do
      expect(connection).to receive(:execute).
        with("COMMENT ON TABLE \"users\" IS NULL;")

      connection.remove_table_comment("users")
    end

    it "#remove_column_comment" do
      expect(connection).to receive(:execute).
        with("COMMENT ON COLUMN \"users\".\"name\" IS NULL;")

      connection.remove_column_comment("users", "name")
    end

    it "#remove_column_comments" do
      expect(connection).to receive(:remove_column_comment).with("users", "name")
      expect(connection).to receive(:remove_column_comment).with("users", "email")

      connection.remove_column_comments("users", "name", "email")
    end

    it "#remove_index_comment" do
      expect(connection).to receive(:execute).
        with("COMMENT ON INDEX index_users_on_email IS NULL;")
      connection.remove_index_comment("index_users_on_email")
    end

    it "#comments" do
      connection.set_table_comment("users", "Users list")
      connection.set_column_comment("users", "email", "User email")

      result = connection.comments("users")

      expect(result).to include([nil, 'Users list'])
      expect(result).to include(['email', 'User email'])
    end

    it "#index_comments" do
      connection.set_index_comment("index_users_on_email", "Index on user email")
      connection.set_index_comment("index_users_on_name", "Index on user name")

      result = connection.index_comments

      expect(result).to include(['public', 'index_users_on_email', 'Index on user email'])
      expect(result).to include(['public', 'index_users_on_name', 'Index on user name'])
    end
  end
end
