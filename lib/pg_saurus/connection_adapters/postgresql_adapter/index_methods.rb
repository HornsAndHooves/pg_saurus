# Provides methods to extend {ActiveRecord::ConnectionAdapters::SchemaStatements}
# to support index features.
module PgSaurus::ConnectionAdapters::PostgreSQLAdapter::IndexMethods
  def supports_partial_index?
    true
  end

  # Overrides ActiveRecord::ConnectionAdapters::SchemaStatements.index_name
  # to support schema notation.  Converts dots in index name to underscores.
  #
  # === Example
  #  add_index 'demography.citizens', :country_id
  #  # produces
  #  CREATE INDEX "index_demography_citizens_on_country_id" ON "demography"."citizens" ("country_id")
  #  # instead of
  #  CREATE INDEX "index_demography.citizens_on_country_id" ON "demography"."citizens" ("country_id")
  #
  def index_name(table_name, options) #:nodoc:
    super.gsub('.','_')
  end
end
