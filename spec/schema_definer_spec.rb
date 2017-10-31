# frozen_string_literal: true

class Person; include Surrealist; end

RSpec.describe Surrealist::SchemaDefiner do
  let(:instance) { Person }

  context 'when hash is passed' do
    let(:schema) { Hash[a: 1, b: {}] }

    before { described_class.call(instance, schema) }

    it 'defines a method on class' do
      expect(instance.new.class.instance_variable_get('@__surrealist_schema')).to eq(schema)
    end
  end

  context 'when something else is passed' do
    shared_examples 'error is raised' do
      specify do
        expect { described_class.call(instance, schema) }
          .to raise_error(Surrealist::InvalidSchemaError, 'Schema should be defined as a hash')
      end
    end

    context 'with array' do
      let(:schema) { %w[it is an array] }

      it_behaves_like 'error is raised'
    end

    context 'with struct' do
      let(:schema) { Struct.new(:a, :b) }

      it_behaves_like 'error is raised'
    end

    context 'with number' do
      let(:schema) { 2 }

      it_behaves_like 'error is raised'
    end

    context 'with string' do
      let(:schema) { 'schema' }

      it_behaves_like 'error is raised'
    end
  end
end
