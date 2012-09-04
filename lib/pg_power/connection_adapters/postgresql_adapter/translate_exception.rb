module PgPower::ConnectionAdapters::PostgreSQLAdapter::TranslateException
  INSUFFICIENT_PRIVILEGE = "42501"

  # Intercept insufficient privilege PGError and raise active_record wrapped database exception
  def translate_exception(exception, message)
    case exception.result.try(:error_field, PGresult::PG_DIAG_SQLSTATE)
      when INSUFFICIENT_PRIVILEGE
        exc_message = exception.result.try(:error_field, PGresult::PG_DIAG_MESSAGE_PRIMARY)
        exc_message ||= message
        ::ActiveRecord::InsufficientPrivilege.new(exc_message, exception)
      else
        super
    end
  end
end