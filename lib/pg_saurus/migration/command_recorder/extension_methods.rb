# Provides methods to extend ActiveRecord::Migration::CommandRecorder to
# support extensions feature.
module  PgSaurus::Migration::CommandRecorder::ExtensionMethods
  # :nodoc:
  def create_extension(*args)
    record(:create_extension, args)
  end

  # :nodoc:
  def drop_extension(*args)
    record(:drop_extension, args)
  end

  # :nodoc:
  def invert_create_extension(args)
    extension_name = args.first
    [:drop_extension, [extension_name]]
  end

  # :nodoc:
  def invert_drop_extension(args)
    extension_name = args.first
    [:create_extension, [extension_name]]
  end
end
