# frozen_string_literal: true

require_relative '../lib/surrealist'

RSpec.describe Surrealist::Utils do
  describe '#deep_copy' do
    subject(:copy) { described_class.deep_copy(object) }

    shared_examples 'object is cloned deeply' do
      specify do
        expect(copy).to eq(object)
        expect(copy).to eql(object)
        expect(copy).not_to equal(object)
      end
    end

    context 'hash' do
      let(:object) { Hash[a: 3, nested: { key: :value }] }

      it_behaves_like 'object is cloned deeply'
    end
  end

  describe '#camelize_hash' do
    subject(:camelized_hash) { described_class.camelize_hash(hash) }

    context 'not nested hash' do
      let(:hash) { Hash[snake_key: 'some value'] }

      it { expect(camelized_hash.keys.first).to eq(:snakeKey) }
    end

    context 'nested hash' do
      let(:hash) { Hash[snake_key: { nested_key: { one_more_level: true } }] }

      it 'camelizes hash recursively' do
        expect(camelized_hash).to eq(snakeKey: { nestedKey: { oneMoreLevel: true } })
      end
    end

    context 'mixed symbols and string' do
      let(:hash) { Hash[snake_key: { 'nested_key' => { 'one_more_level': true } }] }

      it 'camelizes hash recursively' do
        expect(camelized_hash).to eq(snakeKey: { 'nestedKey' => { 'oneMoreLevel': true } })
      end
    end

    context 'array as hash key' do
      let(:hash) { Hash[['some_key'] => 'value'] }

      it { expect(camelized_hash.keys.first).to eq(['some_key']) }
    end
  end
end
