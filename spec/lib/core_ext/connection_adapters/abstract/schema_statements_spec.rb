require 'spec_helper'

describe ActiveRecord::ConnectionAdapters::SchemaStatements do
  describe '#add_index' do
    let(:expected_query) do
      'CREATE  INDEX CONCURRENTLY "index_users_on_phone_number" ON "users" ("phone_number")'
    end

    before { ActiveRecord::Base.connection.stub(:execute) }


    it 'concurrently creates index' do
      ActiveRecord::Base.connection.should_receive(:execute) do |query|
        query.should == expected_query
      end

      ActiveRecord::Migration.add_index :users, :phone_number, :concurrently => true
      ActiveRecord::Migration.process_postponed_queries
    end

    it 'raises index exists error' do
      ActiveRecord::Base.connection.stub(:index_exists? => true)
      ActiveRecord::Base.connection.should_receive(:index_exists?).once

      ActiveRecord::Migration.add_index :users, :phone_number, :concurrently => true

      expect {
        ActiveRecord::Migration.process_postponed_queries
      }.to raise_exception(::PgPower::IndexExistsError)
    end
  end

  describe '#index_name' do
    let(:connection) { ActiveRecord::Base.connection }

    it "returns options[:name] if it's present" do
      expect(connection.index_name("sometable", name: "somename")).to eq "somename"
    end

    it "raises ArgumentError if there is no :column or :name in options" do
      expect {
        connection.index_name("sometable", {})
      }.to raise_error(ArgumentError, "You must specify the index name")
    end
  end
end
