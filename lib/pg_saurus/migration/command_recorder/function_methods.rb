# Methods to extend ActiveRecord::Migration::CommandRecorder to
# support database functions.
module  PgSaurus::Migration::CommandRecorder::FunctionMethods

  # :nodoc
  def create_function(*args)
    record :create_function, args
  end

  # :nodoc
  def drop_function(*args)
    record :drop_function, args
  end

  # :nodoc
  def invert_create_function(args)
    function_name = args.first
    schema        = args.last[:schema]

    [:drop_function, [function_name, { schema: schema }]]
  end

end
