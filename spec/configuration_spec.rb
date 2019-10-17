# frozen_string_literal: true

RSpec.describe Surrealist::Configuration do
  describe 'initialization' do
    context 'without options' do
      subject { described_class.new }

      it 'is identical to default configuration' do
        expect(subject).to eq(described_class::DEFAULT)
      end

      it 'initializes with builtin type system by default' do
        expect(subject.type_system).to eq(Surrealist::TypeSystems::Builtin)
      end
    end

    context 'with options' do
      subject { described_class.new(options) }

      context 'with valid options' do
        let(:options) do
          {
            camelize: true,
            include_root: true,
            include_namespaces: true,
            root: 'some_root',
            namespace_nesting_level: 69,
            type_system: :builtin,
          }
        end

        it 'initializes correctly' do
          expect(subject).to have_attributes(
            camelize: true,
            camelize?: true,
            include_root: true,
            include_root?: true,
            include_namespaces: true,
            include_namespaces?: true,
            root: 'some_root',
            namespace_nesting_level: 69,
            type_system: Surrealist::TypeSystems::Builtin,
          )
        end
      end

      context 'with invalid options' do
        INVALID_PARAMS.each do |hash|
          it "raises ArgumentError with #{hash} params" do
            expect { described_class.new(hash) }.to raise_error(ArgumentError, /Expected.*to be.*, got/)
          end
        end
      end
    end

    describe 'type system options' do
      subject { described_class.new(options).type_system }

      let(:options) { { type_system: type_system } }

      context 'default' do
        let(:type_system) { nil }

        it { is_expected.to eq(Surrealist::TypeSystems::Builtin) }
      end

      context 'builtin' do
        let(:type_system) { :builtin }

        it { is_expected.to eq(Surrealist::TypeSystems::Builtin) }
      end

      context 'dry_types' do
        let(:type_system) { :dry_types }

        it { is_expected.to eq(Surrealist::TypeSystems::DryTypes) }
      end

      context 'custom type system' do
        let(:my_type_system) { double }
        let(:type_system) { my_type_system }

        it { is_expected.to eq(my_type_system) }
      end
    end
  end

  describe 'post-initialization' do
    subject { described_class.new }

    it 'validates options set after initialization' do
      expect { subject.include_root = 'kek pek' }.to raise_error(
        ArgumentError,
        'Expected `include_root` to be either true, false or nil, got kek pek',
      )
    end
  end
end
