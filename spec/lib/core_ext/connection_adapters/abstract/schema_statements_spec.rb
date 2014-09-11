require 'spec_helper'

describe ActiveRecord::ConnectionAdapters::SchemaStatements do
  describe '#add_index' do
    let(:expected_query) do
      'CREATE  INDEX CONCURRENTLY "index_users_on_phone_number" ON "users" ("phone_number")'
    end

    it 'concurrently creates index' do
      expect(ActiveRecord::Base.connection).to receive(:execute) do |query|
        query.should == expected_query
      end

      ActiveRecord::Migration.add_index :users, :phone_number, :concurrently => true
      ActiveRecord::Migration.process_postponed_queries
    end

    it 'raises index exists error' do
      expect(ActiveRecord::Base.connection).
        to receive(:index_exists?).once.and_return(true)

      ActiveRecord::Migration.add_index :users, :phone_number, :concurrently => true

      expect {
        ActiveRecord::Migration.process_postponed_queries
      }.to raise_exception(::PgSaurus::IndexExistsError)
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
