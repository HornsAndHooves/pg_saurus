require 'fake_connection'
require 'rubygems'
gem 'test-unit'
require 'test/unit'
require 'active_record'
require 'pg_comment/schema_dumper'

class SchemaDumperTest < Test::Unit::TestCase
  class SchemaDumpContainer
    def initialize
      @connection = FakeConnection.new( :comments => [[nil, 'table\'s comment'],
                                                      ['c1', 'column1 comment'],
                                                      ['c2', 'column\'s comment']] )
    end

    def self.alias_method_chain(*args)
      #Does nothing
    end

    include PgComment::SchemaDumper

    public :dump_comments
  end

  class Stream
    attr_reader :stream_results

    def puts(str = nil)
      @stream_results ||= []
      @stream_results << str unless str.nil?
    end
  end

  def setup
    @fake_table = 'my_table'
    @expected = ["  set_table_comment '#{@fake_table}', 'table\\'s comment'",
                 "  set_column_comment '#{@fake_table}', 'c1', 'column1 comment'",
                 "  set_column_comment '#{@fake_table}', 'c2', 'column\\'s comment'"].join("\n")
  end

  def test_dump_comments
    sd = SchemaDumpContainer.new
    stream = Stream.new
    sd.dump_comments @fake_table, stream
    assert_equal @expected, stream.stream_results[0]
  end
end