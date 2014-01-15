require 'spec_helper'

describe ActiveRecord::ConnectionAdapters::PostgreSQLAdapter do
  let(:connection) { ActiveRecord::Base.connection }
  subject { connection}

  describe '#tables' do
    it 'returns tables from public schema' do
      connection.tables.should include "users"
    end

    it 'returns tables non public schemas' do
      connection.tables.should include "demography.cities"
    end
  end
end
