class FakeConnection
  def initialize(args = {})
    @comments = args[:comments]
  end

  def comments(table_name)
    @comments
  end
end