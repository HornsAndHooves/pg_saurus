require 'spec_helper'

describe ActiveRecord::SchemaDumper do
  
  describe '.dump' do
    before(:all) do
      stream = StringIO.new
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, stream)
      @dump = stream.string
    end

    it 'creates schemas' do
      @dump.should =~ /create_schema "demography"/
    end

    it 'creates tables' do
      @dump.should =~ /create_table "users"/
      @dump.should =~ /create_table "demography.citizens"/
      @dump.should =~ /create_table "demography.countries"/ 
    end

    it 'creates indexes' do
      @dump.should =~ /add_index "users", \["name"\]/
      @dump.should =~ /add_index "demography\.citizens", \["country_id"\]/
      @dump.should =~ /add_index "demography\.citizens", \["user_id"\]/
    end

    it 'foreign keys' do
      @dump.should =~ /add_foreign_key "demography\.citizens", "users"/
      @dump.should =~ /add_foreign_key "pets", "users"/
    end
  end
end
