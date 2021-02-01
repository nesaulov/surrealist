# frozen_string_literal: true

RSpec.describe Surrealist::StringUtils do
  describe '#underscore' do
    let(:expectations) do
      %w[
        camel_case camel_back name_space triple_name_space
        camel_back_name_space snake_case snake_case_namespace
        with1_numbers with_dashes_and_namespaces
      ]
    end

    %w[
      CamelCase camelBack Name::Space Triple::Name::Space camel::BackNameSpace
      snake_case snake_case::Namespace With1::Numbers with-dashes::and-Namespaces
    ].each_with_index do |string, index|
      it "underscores #{string}" do
        expect(described_class.underscore(string)).to eq(expectations[index])
      end
    end
  end

  describe '#camelize' do
    let(:camelback_expectations) do
      %w[
        camelCase camelBack nameSpace tripleNameSpace
        camelBackNameSpace snakeCase snakeCaseNamespace
        with1Numbers withDashesAndNamespaces camelBack
        CamelCase
      ]
    end

    let(:camelcase_expectations) do
      %w[
        CamelCase CamelBack NameSpace TripleNameSpace
        CamelBackNameSpace SnakeCase SnakeCaseNamespace
        With1Numbers WithDashesAndNamespaces Camelback
        Camelcase
      ]
    end

    %w[
      camel_case camel_back name_space triple_name_space
      camel_back_name_space snake_case snake_case_namespace
      with1_numbers with_dashes_and_namespaces camelBack
      CamelCase
    ].each_with_index do |string, index|
      it "converts #{string} to camelBack" do
        expect(described_class.camelize(string, first_upper: false)).to eq(camelback_expectations[index])
      end

      it "converts #{string} to CamelCase" do
        expect(described_class.camelize(string)).to eq(camelcase_expectations[index])
      end
    end
  end

  describe '#extract class' do
    let(:expectations) do
      %w[
        camelCase camelBack space space backNameSpace
        snake_case namespace numbers and-Namespaces
        numbers 1Numbers nesting :Columns
      ]
    end

    %w[
      CamelCase camelBack Name::Space Triple::Name::Space camel::BackNameSpace
      snake_case snake_case::Namespace With1::Numbers with-dashes::and-Namespaces
      with1::Numbers with::1Numbers Weird::::Nesting Three:::Columns
    ].each_with_index do |string, index|
      it "extracts bottom-level class from #{string}" do
        expect(described_class.extract_class(string)).to eq(expectations[index])
      end
    end
  end

  describe '#break_namespaces' do
    let(:snake_expectations) do
      [
        { camel_case: {} }, { camel_back: {} }, { name: { space: {} } },
        { triple: { name: { space: {} } } }, { camel: { back_name_space: {} } }, { snake_case: {} },
        { snake_case: { name_space: {} } }, { with1: { numbers: {} } },
        { with_dashes: { and_namespaces: {} } }
      ]
    end

    let(:camelized_expectations) do
      [
        { camelCase: {} }, { camelBack: {} }, { name: { space: {} } },
        { triple: { name: { space: {} } } }, { camel: { backNameSpace: {} } }, { snakeCase: {} },
        { snakeCase: { nameSpace: {} } }, { with1: { numbers: {} } },
        { 'with-dashes': { 'and-Namespaces': {} } }
      ]
    end

    let(:nested_expectations) do
      [
        { camel_case: {} }, { camel_back: {} }, { name: { space: {} } },
        { name: { space: {} } }, { back_name_space: { then_snake_case: {} } }, { to: { camel_case: {} } },
        { name_space_maybe: { another: {} } }, { with1: { numbers: {} } },
        { with_dashes: { and_namespaces: {} } }
      ]
    end

    let(:camelized_nested_expectations) do
      [
        { camelCase: {} }, { camelBack: {} }, { name: { space: {} } },
        { name: { space: {} } }, { backNameSpace: { thenSnakeCase: {} } }, { to: { camelCase: {} } },
        { nameSpaceMaybe: { another: {} } }, { with1: { numbers: {} } },
        { 'with-dashes': { 'and-Namespaces': {} } }
      ]
    end

    %w[
      CamelCase camelBack Name::Space Triple::Name::Space camel::BackNameSpace
      snake_case snake_case::NameSpace With1::Numbers with-dashes::and-Namespaces
    ].each_with_index do |klass, index|
      it "breaks namespaces from #{klass} with default nesting level" do
        expect(described_class.break_namespaces(klass, false, 666))
          .to eq(snake_expectations[index])
      end

      it "breaks namespaces from #{klass} & camelizes" do
        expect(described_class.break_namespaces(klass, true, 666))
          .to eq(camelized_expectations[index])
      end

      it 'raises exception on nesting_level == 0' do
        expect { described_class.break_namespaces(klass, true, 0) }
          .to raise_error(ArgumentError,
                          'Expected `namespaces_nesting_level` to be a positive integer, got: 0')
      end
    end

    %w[
      CamelCase camelBack Name::Space Triple::Name::Space camel::BackNameSpace::then_snake_case
      snake_case::To::CamelCase snake_case::NameSpace_maybe::Another Namespace::With1::Numbers
      Another::with-dashes::and-Namespaces
    ].each_with_index do |klass, index|
      it "breaks namespaces from #{klass} with nesting level == 2" do
        expect(described_class.break_namespaces(klass, false, 2))
          .to eq(nested_expectations[index])
      end

      it "breaks namespaces from #{klass} with nesting level == 2 & camelizes them" do
        expect(described_class.break_namespaces(klass, true, 2))
          .to eq(camelized_nested_expectations[index])
      end
    end
  end
end
