# frozen_string_literal: true

require_relative '../lib/surrealist'
require_relative './carriers/params'
RSpec.describe Surrealist::Carrier do
  describe '#call' do
    context 'invalid arguments' do
      INVALID_PARAMS.each do |hash|
        it "raises ArgumentError with #{hash} params" do
          expect { described_class.call(hash) }.to raise_error(ArgumentError, /Expected.*to be.*, got/)
        end
      end
    end

    context 'valid arguments' do
      VALID_PARAMS.each do |hash|
        result = described_class.call(hash)
        %i[camelize include_namespaces include_root namespaces_nesting_level root].each do |method|
          it "stores #{method} in Carrier and returns self for #{hash}" do
            expect(result).to be_a(Surrealist::Carrier)
            expect(result.send(method)).to eq(hash[method])
          end
        end
      end
    end
  end
end
