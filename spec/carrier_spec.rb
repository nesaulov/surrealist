# frozen_string_literal: true

RSpec.describe Surrealist::Carrier do
  describe '#call' do
    context 'invalid arguments' do
      INVALID_PARAMS.each do |hsh|
        it "raises ArgumentError with #{hsh} params" do
          expect { described_class.call(**hsh) }.to raise_error(ArgumentError, /Expected.*to be.*, got/)
        end
      end
    end

    context 'valid arguments' do
      VALID_PARAMS.each do |hsh|
        result = described_class.call(**hsh)
        %i[camelize include_namespaces include_root namespaces_nesting_level root].each do |method|
          it "stores #{method} in Carrier and returns self for #{hsh}" do
            expect(result).to be_a(Surrealist::Carrier)
            expect(result.send(method)).to eq(hsh[method])
          end
        end
      end
    end
  end
end
