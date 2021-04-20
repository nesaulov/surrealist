# frozen_string_literal: true

RSpec.describe Surrealist::HashUtils do
  describe '#camelize_hash' do
    subject(:camelized_hash) { described_class.camelize_hash(hash) }

    context 'not nested hash' do
      let(:hash) { { snake_key: 'some value' } }

      it { expect(camelized_hash.keys.first).to eq(:snakeKey) }
    end

    context 'nested hash' do
      let(:hash) { { snake_key: { nested_key: { one_more_level: true } } } }

      it 'camelizes hash recursively' do
        expect(camelized_hash).to eq(snakeKey: { nestedKey: { oneMoreLevel: true } })
      end
    end

    context 'mixed symbols and string' do
      let(:hash) { { snake_key: { 'nested_key' => { 'one_more_level': true } } } }

      it 'camelizes hash recursively' do
        expect(camelized_hash).to eq(snakeKey: { 'nestedKey' => { 'oneMoreLevel': true } })
      end
    end

    context 'array as hash key' do
      let(:hash) { { ['some_key'] => 'value' } }

      it { expect(camelized_hash.keys.first).to eq(['some_key']) }
    end
  end
end
