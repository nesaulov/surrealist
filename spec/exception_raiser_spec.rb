# frozen_string_literal: true

RSpec.describe Surrealist::ExceptionRaiser do
  describe '.raise_invalid_key!' do
    let(:backtrace) { %w[a b c] }

    it 'preserves exception backtrace and displays correct message' do
      raise NoMethodError, 'my error message', backtrace
    rescue NoMethodError => e
      begin
        described_class.raise_invalid_key!(e)
      rescue Surrealist::UndefinedMethodError => e
        expect(e.message).to eq(
          "my error message. " \
            "You have probably defined a key " \
            "in the schema that doesn't have a corresponding method.",
        )
        expect(e.backtrace).to eq(backtrace)
      end
    end
  end
end
