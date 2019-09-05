module PgSaurus::ConnectionAdapters
  # Class to store index parameters
  # Overrides ActiveRecord::ConnectionAdapters::IndexDefinition
  # with the additional parameters.
  class IndexDefinition # :nodoc:
    attr_reader :table, :name, :unique, :columns, :lengths, :orders, :opclasses,
                :where, :type, :using, :comment, :access_method

    def initialize(
      table,
      name,
      unique = false,
      columns = [],
      lengths: {},
      orders: {},
      opclasses: {},
      where: nil,
      type: nil,
      using: nil,
      comment: nil,
      access_method: nil
    )
      @table = table
      @name = name
      @unique = unique
      @columns = columns
      @lengths = concise_options(lengths)
      @orders = concise_options(orders)
      @opclasses = concise_options(opclasses)
      @where = where
      @type = type
      @using = using
      @comment = comment
      @access_method = access_method
    end

    private
      def concise_options(options)
        if columns.size == options.size && options.values.uniq.size == 1
          options.values.first
        else
          options
        end
      end
  end
end
