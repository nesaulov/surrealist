# frozen_string_literal: true

require_relative '../lib/surrealist'

class NullCarrier
  attr_reader :camelize, :include_root, :include_namespaces, :namespaces_nesting_level

  def initialize(camelize = false)
    @camelize                 = camelize
    @include_root             = false
    @include_namespaces       = false
    @namespaces_nesting_level = Surrealist::DEFAULT_NESTING_LEVEL
  end
end

RSpec.describe Surrealist::Copier do
  describe '#deep_copy' do
    shared_examples 'hash is cloned deeply and it`s structure is not changed' do
      specify do
        expect(copy).to eq(object)
        expect(copy).to eql(object)
        expect(copy).not_to equal(object)
      end
    end

    shared_examples 'UnknownRootError is raised' do
      specify do
        expect { copy }.to raise_error(Surrealist::UnknownRootError, error)
      end
    end

    shared_examples 'schema is camelized and wrapped in the klass root key' do
      specify do
        expect(copy).to eq(someClass: { a: 3, nested_thing: { key: :value } })
      end
    end

    shared_examples 'schema is wrapped in the klass root key' do
      specify do
        expect(copy).to eq(some_class: { a: 3, nested_thing: { key: :value } })
      end
    end

    let(:object) { Hash[a: 3, nested_thing: { key: :value }] }
    let(:klass) { 'SomeClass' }
    let(:error) { "Can't wrap schema in root key - class name was not passed" }

    args_with_root_and_camelize = [
      { camelize: true, include_namespaces: true, include_root: true, namespaces_nesting_level: 3 },
      { camelize: true, include_namespaces: true, include_root: true, namespaces_nesting_level: 666 },
      { camelize: true, include_namespaces: false, include_root: true, namespaces_nesting_level: 3 },
      { camelize: true, include_namespaces: false, include_root: true, namespaces_nesting_level: 666 },
      { camelize: true, include_namespaces: true, include_root: false, namespaces_nesting_level: 3 },
      { camelize: true, include_namespaces: true, include_root: false, namespaces_nesting_level: 666 },
      { camelize: true, include_namespaces: false, include_root: false, namespaces_nesting_level: 3 },
    ]

    args_with_root_and_without_camelize = [
      { camelize: false, include_namespaces: true, include_root: true, namespaces_nesting_level: 3 },
      { camelize: false, include_namespaces: true, include_root: true, namespaces_nesting_level: 666 },
      { camelize: false, include_namespaces: false, include_root: true, namespaces_nesting_level: 3 },
      { camelize: false, include_namespaces: false, include_root: true, namespaces_nesting_level: 666 },
      { camelize: false, include_namespaces: true, include_root: false, namespaces_nesting_level: 3 },
      { camelize: false, include_namespaces: true, include_root: false, namespaces_nesting_level: 666 },
      { camelize: false, include_namespaces: false, include_root: false, namespaces_nesting_level: 3 },
    ]

    args_without_root = [
      { camelize: false, include_namespaces: false, include_root: false, namespaces_nesting_level: 666 },
      { camelize: true, include_namespaces: false, include_root: false, namespaces_nesting_level: 666 },
    ]

    context 'with `camelize: true`' do
      args_with_root_and_camelize.each do |hash|
        carrier = Surrealist::Carrier.call(hash)
        it_behaves_like 'schema is camelized and wrapped in the klass root key' do
          let(:copy) { described_class.deep_copy(hash: object, klass: klass, carrier: carrier) }
        end
      end
    end

    context 'with `camelize: false`' do
      args_with_root_and_without_camelize.each do |hash|
        carrier = Surrealist::Carrier.call(hash)
        it_behaves_like 'schema is wrapped in the klass root key' do
          let(:copy) { described_class.deep_copy(hash: object, klass: klass, carrier: carrier) }
        end
      end
    end

    context 'without klass' do
      args_with_root_and_camelize.zip(args_with_root_and_without_camelize).flatten.compact.each do |hash|
        carrier = Surrealist::Carrier.call(hash)
        it_behaves_like 'UnknownRootError is raised' do
          let(:copy) { described_class.deep_copy(hash: object, carrier: carrier) }
        end
      end
    end

    context 'without wrapping' do
      args_without_root.each do |hash|
        carrier = Surrealist::Carrier.call(hash)
        it_behaves_like 'hash is cloned deeply and it`s structure is not changed' do
          let(:copy) { described_class.deep_copy(hash: object, klass: klass, carrier: carrier) }
        end
      end
    end

    context 'with NullCarrier' do
      context 'hash & carrier' do
        let(:copy) { described_class.deep_copy(hash: object, carrier: NullCarrier.new) }

        it_behaves_like 'hash is cloned deeply and it`s structure is not changed'
      end

      context 'with camelize' do
        let(:copy) { described_class.deep_copy(hash: object, carrier: NullCarrier.new(true)) }

        it_behaves_like 'hash is cloned deeply and it`s structure is not changed'
      end

      context 'with klass' do
        let(:copy) { described_class.deep_copy(hash: object, klass: klass, carrier: NullCarrier.new) }

        it_behaves_like 'hash is cloned deeply and it`s structure is not changed'
      end

      context 'with klass and camelize' do
        let(:copy) do
          described_class.deep_copy(hash: object, klass: klass, carrier: NullCarrier.new(true))
        end

        it_behaves_like 'hash is cloned deeply and it`s structure is not changed'
      end
    end
  end
end
