require 'rubygems'
gem 'test-unit'
require 'test/unit'
require 'pg_comment/connection_adapters/postgresql_adapter'

class PostgreSQLAdapterTest < Test::Unit::TestCase
  class Adapter
    attr_reader :buffer
    def select_results=(val)
      @select_results = val
    end

    def select_all(*args)
      @select_results
    end

    def quote_table_name(table_name)
      table_name
    end

    def quote_column_name(column_name)
      column_name
    end

    def execute(sql)
      @buffer ||= []
      @buffer << sql
    end

    include PgComment::ConnectionAdapters::PostgreSQLAdapter
  end

  def setup
    @adapter = Adapter.new
  end

  def test_table_comments_sql
    expected = [ "COMMENT ON TABLE my_table IS $$table comment$$;",
                 "COMMENT ON TABLE my_table IS NULL;" ]
    @adapter.set_table_comment :my_table, 'table comment'
    @adapter.remove_table_comment :my_table
    assert_equal expected, @adapter.buffer
  end

  def test_column_comment_sql
    expected = [ "COMMENT ON COLUMN my_table.my_column IS $$column comment$$;",
                 "COMMENT ON COLUMN my_table.my_column IS NULL;" ]
    @adapter.set_column_comment :my_table, :my_column, 'column comment'
    @adapter.remove_column_comment :my_table, :my_column
    assert_equal expected, @adapter.buffer
  end

  def test_column_comments_sql
    expected = [ "COMMENT ON COLUMN my_table.column1 IS $$column comment 1$$;",
                 "COMMENT ON COLUMN my_table.column2 IS $$column comment 2$$;" ]

    @adapter.set_column_comments :my_table, :column1 => 'column comment 1', :column2 => 'column comment 2'
    assert_equal expected, @adapter.buffer
  end

  def test_sql_generation
    expected = [ "COMMENT ON TABLE my_table IS $$table comment$$;",
                 "COMMENT ON COLUMN my_table.my_column IS $$column comment$$;",
                 "COMMENT ON TABLE my_table IS NULL;",
                 "COMMENT ON COLUMN my_table.my_column IS NULL;" ]

    @adapter.set_table_comment :my_table, 'table comment'
    @adapter.set_column_comment :my_table, :my_column, 'column comment'
    @adapter.remove_table_comment :my_table
    @adapter.remove_column_comment :my_table, :my_column
    assert_equal expected, @adapter.buffer
  end

  def test_comments
    expected = [ { 'column_name' => nil, 'comment' => 'table comment' },
                 { 'column_name' => 'column1', 'comment' => 'column comment 1' },
                 { 'column_name' => 'column2', 'comment' => 'column comment 2' } ]
    @adapter.select_results = expected
    results = @adapter.comments( nil )
    assert_not_nil results
    assert_equal 3, results.size, "Should have three comment rows."
    results.each_with_index do |comment_row, index|
      column_name = comment_row[0]
      comment = comment_row[1]
      assert_equal expected[index]['column_name'], column_name
      assert_equal expected[index]['comment'], comment
    end
  end

end