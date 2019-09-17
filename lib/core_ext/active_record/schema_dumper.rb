module ActiveRecord #:nodoc:
  # Patched version:  3.1.3
  # Patched methods::
  #   * indexes
  class SchemaDumper #:nodoc:
    # Writes out index-related details to the schema stream
    #
    # == Patch:
    # Add support of skip_column_quoting option for json indexes.
    #
    def index_parts(index)
      is_json_index = index.columns.is_a?(String) && index.columns =~ /^(.+->.+)$/

      index_parts = [
        index.columns.inspect,
        "name: #{index.name.inspect}",
      ]
      index_parts << "unique: true" if index.unique
      index_parts << "length: #{format_index_parts(index.lengths)}" if index.lengths.present?
      index_parts << "order: #{format_index_parts(index.orders)}" if index.orders.present?
      index_parts << "opclass: #{format_index_parts(index.opclasses)}" if index.opclasses.present?
      index_parts << "where: #{index.where.inspect}" if index.where
      index_parts << "using: #{index.using.inspect}" if !@connection.default_index_type?(index)
      index_parts << "skip_column_quoting: true" if is_json_index
      index_parts << "type: #{index.type.inspect}" if index.type
      index_parts << "comment: #{index.comment.inspect}" if index.comment
      index_parts
    end
  end
end
