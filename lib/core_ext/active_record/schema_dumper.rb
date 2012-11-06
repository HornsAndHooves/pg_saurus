module ActiveRecord #:nodoc:
  # Patched version:  3.1.3
  # Patched methods::
  #   * indexes
  class SchemaDumper #:nodoc:
    # Writes out index-related details to the schema stream
    #
    # == Patch reason:
    # {ActiveRecord::SchemaDumper#indexes} does not support writing out
    # details related to partial indexes.
    #
    # == Patch:
    # Append :where clause if there's a partial index
    #
    def indexes(table, stream)
      if (indexes = @connection.indexes(table)).any?
        add_index_statements = indexes.map do |index|
          statement_parts = [
            ('add_index ' + index.table.inspect),
            index.columns.inspect,
            (':name => ' + index.name.inspect),
          ]
          statement_parts << ':unique => true' if index.unique

          index_lengths = (index.lengths || []).compact
          statement_parts << (':length => ' + Hash[index.columns.zip(index.lengths)].inspect) unless index_lengths.empty?

          # Patch
          #  Append :where clause if a partial index
          statement_parts << (':where => ' + index.where.inspect) if index.where

          statement_parts << (':using => ' + index.access_method.inspect) unless index.access_method.downcase == 'btree'

          '  ' + statement_parts.join(', ')
        end

        stream.puts add_index_statements.sort.join("\n")
        stream.puts
      end
    end
  end
end
