# frozen_string_literal: true

require_relative '../lib/surrealist'

RSpec.describe Surrealist::Copier do
  describe '#deep_copy' do
    shared_examples 'hash is cloned deeply and it`s structure is not changed`' do
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

    context 'only `hash`' do
      let(:copy) { described_class.deep_copy(hash: object) }

      it_behaves_like 'hash is cloned deeply and it`s structure is not changed`'
    end

    context '`hash` & `include_root`' do
      let(:copy) { described_class.deep_copy(hash: object, include_root: true) }

      it_behaves_like 'UnknownRootError is raised'
    end

    context '`hash` & `camelize`' do
      let(:copy) { described_class.deep_copy(hash: object, camelize: true) }

      it_behaves_like 'hash is cloned deeply and it`s structure is not changed`'
    end

    context '`hash` & `klass`' do
      let(:copy) { described_class.deep_copy(hash: object, klass: klass) }

      it_behaves_like 'hash is cloned deeply and it`s structure is not changed`'
    end

    context '`hash` & `include_namespaces`' do
      let(:copy) { described_class.deep_copy(hash: object, include_namespaces: true) }

      it_behaves_like 'UnknownRootError is raised'
    end

    context '`hash` & `nesting_level`' do
      let(:copy) { described_class.deep_copy(hash: object, nesting_level: 45) }

      it_behaves_like 'UnknownRootError is raised'
    end

    context '`hash` & `include_root` & `camelize`' do
      let(:copy) { described_class.deep_copy(hash: object, include_root: true, camelize: true) }

      it_behaves_like 'UnknownRootError is raised'
    end

    context '`hash` & `include_root` & `klass`' do
      let(:copy) do
        described_class.deep_copy(hash: object, include_root: true, klass: klass)
      end

      it_behaves_like 'schema is wrapped in the klass root key'
    end

    context '`hash` & `include_root` & `include_namespaces`' do
      let(:copy) do
        described_class.deep_copy(hash: object, include_namespaces: true, include_root: true)
      end

      it_behaves_like 'UnknownRootError is raised'
    end

    context '`hash` & `include_root` & `nesting_level`' do
      let(:copy) do
        described_class.deep_copy(hash: object, include_root: true, nesting_level: 4)
      end

      it_behaves_like 'UnknownRootError is raised'
    end

    context '`hash` & `camelize` & `klass`' do
      let(:copy) { described_class.deep_copy(hash: object, camelize: true, klass: klass) }

      it_behaves_like 'hash is cloned deeply and it`s structure is not changed`'
    end

    context '`hash` & `camelize` & `include_namespaces`' do
      let(:copy) do
        described_class.deep_copy(hash: object, camelize: true, include_namespaces: true)
      end

      it_behaves_like 'UnknownRootError is raised'
    end

    context '`hash` & `camelize` & `nesting_level`' do
      let(:copy) do
        described_class.deep_copy(hash: object, camelize: true, nesting_level: 43)
      end

      it_behaves_like 'UnknownRootError is raised'
    end

    context '`hash` & `klass` & `include_namespaces`' do
      let(:copy) do
        described_class.deep_copy(hash: object, include_namespaces: true, klass: klass)
      end

      it_behaves_like 'schema is wrapped in the klass root key'
    end

    context '`hash` & `klass` & `nesting_level`' do
      let(:copy) do
        described_class.deep_copy(hash: object, nesting_level: 23, klass: klass)
      end

      it_behaves_like 'schema is wrapped in the klass root key'
    end

    context '`hash` & `include_namespaces` & `nesting_level`' do
      let(:copy) do
        described_class.deep_copy(hash: object, include_namespaces: true, nesting_level: 43)
      end

      it_behaves_like 'UnknownRootError is raised'
    end

    context '`hash` & `include_root` & `klass` & `camelize`' do
      let(:copy) do
        described_class.deep_copy(hash: object, include_root: true, klass: klass, camelize: true)
      end

      it_behaves_like 'schema is camelized and wrapped in the klass root key'
    end

    context '`hash` & `include_root` & `klass` & `include_namespaces`' do
      let(:copy) do
        described_class.deep_copy(hash: object, include_root: true,
                                  klass: klass, include_namespaces: true)
      end

      it_behaves_like 'schema is wrapped in the klass root key'
    end

    context '`hash` & `include_root` & `klass` & `nesting_level`' do
      let(:copy) do
        described_class.deep_copy(hash: object, include_root: true,
                                  klass: klass, nesting_level: 34)
      end

      it_behaves_like 'schema is wrapped in the klass root key'
    end

    context '`hash` & `include_root` & `camelize` & `include_namespaces`' do
      let(:copy) do
        described_class.deep_copy(hash: object, include_root: true,
                                  camelize: true, include_namespaces: true)
      end

      it_behaves_like 'UnknownRootError is raised'
    end

    context '`hash` & `include_root` & `camelize` & `nesting_level`' do
      let(:copy) do
        described_class.deep_copy(hash: object, include_root: true,
                                  camelize: true, nesting_level: 23)
      end

      it_behaves_like 'UnknownRootError is raised'
    end

    context '`hash` & `include_root` & `include_namespaces` & `nesting_level`' do
      let(:copy) do
        described_class.deep_copy(hash: object, include_root: true,
                                  include_namespaces: true, nesting_level: 23)
      end

      it_behaves_like 'UnknownRootError is raised'
    end

    context '`hash` & `include_root` & `klass` & `nesting_level`' do
      let(:copy) do
        described_class.deep_copy(hash: object, include_root: true,
                                  klass: klass, nesting_level: 3)
      end

      it_behaves_like 'schema is wrapped in the klass root key'
    end

    context '`hash` & `include_root` & `klass` & `camelize` & `include_namespaces`' do
      let(:copy) do
        described_class.deep_copy(hash: object, include_root: true,
                                  klass: klass, camelize: true, include_namespaces: true)
      end

      it_behaves_like 'schema is camelized and wrapped in the klass root key'
    end

    context '`hash` & `include_root` & `klass` & `camelize` & `nesting_level`' do
      let(:copy) do
        described_class.deep_copy(hash: object, include_root: true,
                                  klass: klass, camelize: true, nesting_level: 3)
      end

      it_behaves_like 'schema is camelized and wrapped in the klass root key'
    end

    context 'nesting_level is not an Integer' do
      let(:copy) { described_class.deep_copy(hash: object, nesting_level: 'wut', klass: klass) }

      it 'raises ArgumentError' do
        expect { copy }
          .to raise_error(ArgumentError,
                          'Expected `namespaces_nesting_level` to be a positive integer, got: wut')
      end
    end
  end
end
