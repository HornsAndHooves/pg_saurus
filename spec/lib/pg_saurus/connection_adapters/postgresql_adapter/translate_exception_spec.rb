require 'spec_helper'

describe PgSaurus::ConnectionAdapters::PostgreSQLAdapter::TranslateException do
  let(:connection) { ActiveRecord::Base.connection }

  describe "#translate_exception" do
    it "intercepts insufficient privilege PGError" do
      exception = double("PGError").as_null_object.tap do |error|
        allow(error).to receive(:result) do
          double("PGResult").as_null_object.tap do |result|
            allow(result).
              to receive(:error_field).
              and_return(described_class::INSUFFICIENT_PRIVILEGE)
          end
        end
      end

      translated = connection.send(:translate_exception, exception, "")
      expect(translated).to be_an_instance_of(ActiveRecord::InsufficientPrivilege)
    end
  end
end
