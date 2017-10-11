# frozen_string_literal: true

require_relative '../lib/surrealist'

RSpec.describe Surrealist::Carrier do
  describe '#call' do
    context 'invalid arguments' do
      [
        { camelize: 'NO', include_namespaces: false, include_root: true, namespaces_nesting_level: 3 },
        { camelize: true, include_namespaces: 'false', include_root: true, namespaces_nesting_level: 3 },
        { camelize: true, include_namespaces: false, include_root: true, namespaces_nesting_level: 0 },
        { camelize: true, include_namespaces: false, include_root: false, namespaces_nesting_level: -3 },
        { camelize: true, include_namespaces: false, include_root: 'yep', namespaces_nesting_level: 3 },
        { camelize: 'NO', include_namespaces: false, include_root: true, namespaces_nesting_level: '3' },
        { camelize: 'NO', include_namespaces: false, include_root: true, namespaces_nesting_level: 3.14 },
        { camelize: Integer, include_namespaces: false, include_root: true, namespaces_nesting_level: 3 },
        { camelize: 'NO', include_namespaces: 'no', include_root: true, namespaces_nesting_level: '3.4' },
        { camelize: 'f', include_namespaces: false, include_root: 't', namespaces_nesting_level: true },
      ].each do |hash|
        it "raises ArgumentError with #{hash} params" do
          expect { described_class.call(hash) }.to raise_error(ArgumentError, /Expected.*to be.*, got/)
        end
      end
    end

    context 'valid arguments' do
      [
        { camelize: true,  include_namespaces: true, include_root: true, namespaces_nesting_level: 3 },
        { camelize: false, include_namespaces: true, include_root: true, namespaces_nesting_level: 3 },
        { camelize: false, include_namespaces: false, include_root: true, namespaces_nesting_level: 3 },
        { camelize: false, include_namespaces: false, include_root: false, namespaces_nesting_level: 3 },
        { camelize: true,  include_namespaces: false, include_root: false, namespaces_nesting_level: 3 },
        { camelize: true,  include_namespaces: true, include_root: false, namespaces_nesting_level: 3 },
        { camelize: true,  include_namespaces: false, include_root: true, namespaces_nesting_level: 3 },
        { camelize: true,  include_namespaces: false, include_root: true, namespaces_nesting_level: 435 },
        { camelize: true,  include_namespaces: false, include_root: true, namespaces_nesting_level: 666 },
      ].each do |hash|
        result = described_class.call(hash)
        %i[camelize include_namespaces include_root namespaces_nesting_level].each do |method|
          it "stores #{method} in Carrier and returns self for #{hash}" do
            expect(result).to be_a(Surrealist::Carrier)
            expect(result.send(method)).to eq(hash[method])
          end
        end
      end
    end
  end
end
