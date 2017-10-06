# frozen_string_literal: true

require_relative '../lib/surrealist'

RSpec.describe Surrealist::HashUtils do
  describe '#deep_copy' do
    shared_examples 'hash is cloned deeply and it`s structure is not changed`' do
      specify do
        expect(copy).to eq(object)
        expect(copy).to eql(object)
        expect(copy).not_to equal(object)
      end
    end

    context 'only hash is passed' do
      let(:object) { Hash[a: 3, nested: { key: :value }] }
      let(:copy) { described_class.deep_copy(hash: object) }

      it_behaves_like 'hash is cloned deeply and it`s structure is not changed`'
    end

    context 'include_root is passed' do
      let(:object) { Hash[a: 3, nested_thing: { key: :value }] }
      let(:klass) { 'SomeClass' }

      context 'with `camelize`' do
        let(:copy) do
          described_class.deep_copy(hash: object, include_root: true, klass: klass, camelize: true)
        end

        it 'wraps hash in the klass and camelizes the root key' do
          expect(copy).to eq(someClass: { a: 3, nested_thing: { key: :value } })
        end
      end

      context 'without `camelize`' do
        let(:copy) { described_class.deep_copy(hash: object, include_root: true, klass: klass) }

        it 'wraps hash in the klass' do
          expect(copy).to eq(some_class: { a: 3, nested_thing: { key: :value } })
        end
      end
    end

    context 'hash & klass are passed' do
      let(:object) { Hash[a: 3, nested: { key: :value }] }
      let(:copy) { described_class.deep_copy(hash: object, klass: klass) }
      let(:klass) { 'SomeClass' }

      it_behaves_like 'hash is cloned deeply and it`s structure is not changed`'
    end

    context 'hash & camelize are passed' do
      let(:object) { Hash[a: 3, nested: { key: :value }] }
      let(:copy) { described_class.deep_copy(hash: object, camelize: true) }

      it_behaves_like 'hash is cloned deeply and it`s structure is not changed`'
    end

    context 'include_root is passed without klass' do
      let(:object) { Hash[a: 3, nested: { key: :value }] }
      let(:copy) { described_class.deep_copy(hash: object, include_root: true) }
      let(:error) { "Can't wrap schema in root key - class name was not passed" }

      it 'raises UnknownRootError' do
        expect { copy }.to raise_error(Surrealist::UnknownRootError, error)
      end
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
