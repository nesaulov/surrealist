# frozen_string_literal: true

class NullConfig
  attr_reader :camelize,
              :include_root,
              :include_namespaces,
              :namespace_nesting_level,
              :root,
              :type_system

  alias camelize? camelize
  alias include_root? include_root
  alias include_namespaces? include_namespaces

  def initialize(camelize = false)
    @type_system              = Surrealist::TypeSystems::Builtin
    @camelize                 = camelize
    @include_root             = false
    @include_namespaces       = false
    @namespace_nesting_level  = Surrealist::DEFAULT_NESTING_LEVEL
    @root                     = nil
  end

  def default?
    camelize == false && include_root == false && include_namespaces == false &&
      root.nil? && namespace_nesting_level == Surrealist::DEFAULT_NESTING_LEVEL &&
      type_system == Surrealist::TypeSystems::Builtin
  end
end

RSpec.describe Surrealist::Wrapper do
  describe '#wrap' do
    shared_examples 'UnknownRootError is raised' do
      specify do
        expect { wrapped_hash }.to raise_error(Surrealist::UnknownRootError, error)
      end
    end

    shared_examples 'schema is camelized and wrapped in the klass root key' do
      specify do
        expect(wrapped_hash).to eq(someClass: { a: 3, nested_thing: { key: :value } })
      end
    end

    shared_examples 'schema is wrapped in the klass root key' do
      specify do
        expect(wrapped_hash).to eq(some_class: { a: 3, nested_thing: { key: :value } })
      end
    end

    let(:object) { Hash[a: 3, nested_thing: { key: :value }] }
    let(:klass) { 'SomeClass' }
    let(:error) { "Can't wrap schema in root key - class name was not passed" }
    let(:config) { Surrealist::Configuration::DEFAULT.with_overrides(config_overrides) }

    args_with_root_and_camelize = [
      { camelize: true, include_namespaces: true, include_root: true,
        root: nil, namespaces_nesting_level: 3 },
      { camelize: true, include_namespaces: true, include_root: true,
        root: nil, namespaces_nesting_level: 666 },
      { camelize: true, include_namespaces: false, include_root: true,
        root: nil, namespaces_nesting_level: 3 },
      { camelize: true, include_namespaces: false, include_root: true,
        root: nil, namespaces_nesting_level: 666 },
      { camelize: true, include_namespaces: true, include_root: false,
        root: nil, namespaces_nesting_level: 3 },
      { camelize: true, include_namespaces: true, include_root: false,
        root: nil, namespaces_nesting_level: 666 },
      { camelize: true, include_namespaces: false, include_root: false,
        root: nil, namespaces_nesting_level: 3 },
    ]

    args_with_root_and_without_camelize = [
      { camelize: false, include_namespaces: true, include_root: true,
        root: nil, namespaces_nesting_level: 3 },
      { camelize: false, include_namespaces: true, include_root: true,
        root: nil, namespaces_nesting_level: 666 },
      { camelize: false, include_namespaces: false, include_root: true,
        root: nil, namespaces_nesting_level: 3 },
      { camelize: false, include_namespaces: false, include_root: true,
        root: nil, namespaces_nesting_level: 666 },
      { camelize: false, include_namespaces: true, include_root: false,
        root: nil, namespaces_nesting_level: 3 },
      { camelize: false, include_namespaces: true, include_root: false,
        root: nil, namespaces_nesting_level: 666 },
      { camelize: false, include_namespaces: false, include_root: false,
        root: nil, namespaces_nesting_level: 3 },
    ]

    args_without_root = [
      { camelize: false, include_namespaces: false, include_root: false,
        root: nil, namespaces_nesting_level: 666 },
      { camelize: true, include_namespaces: false, include_root: false,
        root: nil, namespaces_nesting_level: 666 },
    ]

    context 'with `camelize: true`' do
      args_with_root_and_camelize.each do |hash|
        let(:config_overrides) { hash }

        it_behaves_like 'schema is camelized and wrapped in the klass root key' do
          let(:wrapped_hash) { described_class.wrap(object, config, klass) }
        end
      end
    end

    context 'with `camelize: false`' do
      args_with_root_and_without_camelize.each do |hash|
        let(:config_overrides) { hash }

        it_behaves_like 'schema is wrapped in the klass root key' do
          let(:wrapped_hash) { described_class.wrap(object, config, klass) }
        end
      end
    end

    context 'without klass' do
      args_with_root_and_camelize.zip(args_with_root_and_without_camelize).flatten.compact.each do |hash|
        let(:config_overrides) { hash }

        it_behaves_like 'UnknownRootError is raised' do
          let(:wrapped_hash) { described_class.wrap(object, config) }
        end
      end
    end

    context 'without wrapping' do
      args_without_root.each do |hash|
        let(:config_overrides) { hash }

        it_behaves_like 'hash is cloned deeply and it`s structure is not changed' do
          let(:copy) { described_class.wrap(object, config, klass) }
        end
      end
    end

    context 'with NullConfig' do
      context 'hash & config' do
        let(:copy) { described_class.wrap(object, NullConfig.new) }

        it_behaves_like 'hash is cloned deeply and it`s structure is not changed'
      end

      context 'with camelize' do
        let(:copy) { described_class.wrap(object, NullConfig.new(true)) }

        it_behaves_like 'hash is cloned deeply and it`s structure is not changed'
      end

      context 'with klass' do
        let(:copy) { described_class.wrap(object, NullConfig.new, klass) }

        it_behaves_like 'hash is cloned deeply and it`s structure is not changed'
      end

      context 'with klass and camelize' do
        let(:copy) do
          described_class.wrap(object, NullConfig.new(true), klass)
        end

        it_behaves_like 'hash is cloned deeply and it`s structure is not changed'
      end
    end
  end
end
