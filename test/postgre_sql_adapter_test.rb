require 'rubygems'
gem 'test-unit'
require 'test/unit'
require 'pg_comment/connection_adapters/postgresql_adapter'

class PostgreSQLAdapterTest < Test::Unit::TestCase
  class Adapter
    attr_reader :buffer

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
    @expected = ["COMMENT ON TABLE my_table IS $$table comment$$;",
                 "COMMENT ON COLUMN my_table.my_column IS $$column comment$$;",
                 "COMMENT ON TABLE my_table IS NULL;",
                 "COMMENT ON COLUMN my_table.my_column IS NULL;"]
  end

  def test_sql_generation
    a = Adapter.new
    a.set_table_comment :my_table, 'table comment'
    a.set_column_comment :my_table, :my_column, 'column comment'
    a.remove_table_comment :my_table
    a.remove_column_comment :my_table, :my_column
    assert_equal @expected, a.buffer
  end

end