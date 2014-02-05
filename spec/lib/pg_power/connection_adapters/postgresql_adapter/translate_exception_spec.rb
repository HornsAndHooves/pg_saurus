require 'spec_helper'

describe PgPower::ConnectionAdapters::PostgreSQLAdapter::TranslateException do
  let(:connection) { ActiveRecord::Base.connection }

  describe "#translate_exception" do
    it "intercepts insufficient privilege PGError" do
      exception = double("PGError").as_null_object.tap do |error|
        error.stub(:result) do
          double("PGResult").as_null_object.tap do |result|
            result.stub(:error_field).and_return(described_class::INSUFFICIENT_PRIVILEGE)
          end
        end
      end

      translated = connection.send(:translate_exception, exception, "")
      expect(translated).to be_an_instance_of(ActiveRecord::InsufficientPrivilege)
    end
  end
end
