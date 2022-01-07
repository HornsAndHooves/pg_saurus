# Extend ActiveRecord::ConnectionAdapter::PostgreSQLAdapter logic
# to wrap more pg-specific errors into specific exception classes
module PgSaurus::ConnectionAdapters::PostgreSQLAdapter::TranslateException
  # # See http://www.postgresql.org/docs/9.1/static/errcodes-appendix.html
  INSUFFICIENT_PRIVILEGE = "42501"

  # Intercept insufficient privilege PG::Error and raise active_record wrapped database exception
  def translate_exception(exception, message:, sql:, binds:)
    return exception unless exception.respond_to?(:result)
    exception_result = exception.result

    case exception_result.try(:error_field, PG::Result::PG_DIAG_SQLSTATE)
    when INSUFFICIENT_PRIVILEGE
      exc_message = exception_result.try(:error_field, PG::Result::PG_DIAG_MESSAGE_PRIMARY)
      exc_message ||= message
      ::ActiveRecord::InsufficientPrivilege.new(exc_message, sql: sql, binds: binds)
    else
      super
    end
  end
end
