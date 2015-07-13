require 'spec_helper'

describe PgSaurus::ConnectionAdapters::PostgreSQLAdapter::FunctionMethods do

  let(:connection) { ActiveRecord::Base.connection }

  it '.supports_functions?' do
    expect(connection.supports_functions?).to be true
  end

  it '.create_function' do
    sql = <<-SQL
CREATE OR REPLACE FUNCTION public.pets_not_empty()
  RETURNS boolean
  LANGUAGE plpgsql
AS $function$
BEGIN
  IF (SELECT COUNT(*) FROM pets) > 0
  THEN
    RETURN true;
  ELSE
    RETURN false;
  END IF;
END;
$function$
    SQL

    expect(connection).to receive(:execute).with(sql)

    connection.create_function 'pets_not_empty()', :boolean, <<-FUNCTION, schema: 'public'
BEGIN
  IF (SELECT COUNT(*) FROM pets) > 0
  THEN
    RETURN true;
  ELSE
    RETURN false;
  END IF;
END;
    FUNCTION
  end

  it '.drop_function' do
    expect(connection).to receive(:execute).with("DROP FUNCTION foo_bar()")

    connection.drop_function 'foo_bar()'
  end

  it '.functions' do
    function = connection.functions.find{ |f| f.name == 'public.pets_not_empty()' }

    expect(function).to_not be_nil
    expect(function.returning).to eq('boolean')
  end

end
