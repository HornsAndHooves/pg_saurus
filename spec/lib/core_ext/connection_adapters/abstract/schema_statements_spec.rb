require 'spec_helper'

describe ActiveRecord::ConnectionAdapters::SchemaStatements do
  describe '#add_index' do
    context "concurrently creates index" do
      let(:expected_query) do
        'CREATE  INDEX CONCURRENTLY "index_users_on_phone_number" ON "users" ("phone_number")'
      end

      it 'concurrently creates index' do
        ActiveRecord::Migration.clear_queue

        expect(ActiveRecord::Base.connection).to receive(:execute) do |query|
          query.should == expected_query
        end

        ActiveRecord::Migration.add_index :users, :phone_number, concurrently: true
        ActiveRecord::Migration.process_postponed_queries
      end
    end

    context "creates index for column with operator" do
      let(:expected_query) do
        'CREATE  INDEX "index_users_on_phone_number_varchar_pattern_ops" ON "users" (phone_number varchar_pattern_ops)'
      end

      it 'creates index for column with operator' do
        ActiveRecord::Migration.clear_queue

        expect(ActiveRecord::Base.connection).to receive(:execute) do |query|
          query.should == expected_query
        end

        ActiveRecord::Migration.add_index :users, "phone_number varchar_pattern_ops"
        ActiveRecord::Migration.process_postponed_queries
      end
    end

    context "for functional index with longer operator string" do
      let(:expected_query) do
        'CREATE  INDEX "index_users_on_lower_first_name_desc_nulls_last" ' \
        'ON "users" (trim(lower(first_name)) DESC NULLS LAST)'
      end

      it 'creates functional index for column with longer operator string' do
        ActiveRecord::Migration.clear_queue

        expect(ActiveRecord::Base.connection).to receive(:execute) do |query|
          query.should == expected_query
        end

        ActiveRecord::Migration.add_index :users, "trim(lower(first_name)) DESC NULLS LAST"
        ActiveRecord::Migration.process_postponed_queries
      end
    end

    it 'raises index exists error' do
      expect(ActiveRecord::Base.connection).
        to receive(:index_exists?).once.and_return(true)

      ActiveRecord::Migration.add_index :users, :phone_number, concurrently: true

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
