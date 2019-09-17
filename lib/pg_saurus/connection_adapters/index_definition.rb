module PgSaurus::ConnectionAdapters
  # Class to store index parameters
  # Overrides ActiveRecord::ConnectionAdapters::IndexDefinition
  # with the additional parameters.
  class IndexDefinition # :nodoc:
    attr_reader :table, :name, :unique, :columns, :lengths, :orders, :opclasses,
                :where, :type, :using, :comment

    def initialize(
      table,
      name,
      unique  = false,
      columns = [],
      lengths:   {},
      orders:    {},
      opclasses: {},
      where:     nil,
      type:      nil,
      using:     nil,
      comment:   nil
    )
      @table     = table
      @name      = name
      @unique    = unique
      @columns   = columns
      @lengths   = concise_options(lengths)
      @orders    = concise_options(orders)
      @opclasses = concise_options(opclasses)
      @where     = where
      @type      = type
      @using     = using
      @comment   = comment
    end

    private
      # The options or the first value if there's only one unique value and the number of options is the same
      # as the number of columns.
      def concise_options(options)
        if columns.size == options.size && options.values.uniq.size == 1
          options.values.first
        else
          options
        end
      end
  end
end
