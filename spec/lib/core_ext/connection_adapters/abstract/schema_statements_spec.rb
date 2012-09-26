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
end
