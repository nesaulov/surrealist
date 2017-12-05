# frozen_string_literal: true

class Person; include Surrealist; end

RSpec.describe Surrealist::AliasesDefiner do
  let(:instance) { Person }

  context 'when hash is passed' do
    let(:aliases) { Hash[login: :name] }

    before { described_class.call(instance, aliases) }

    it 'defines a method on class' do
      expect(instance.new.class.instance_variable_get('@__surrealist_aliases')).to eq(aliases)
    end
  end

  context 'when something else is passed' do
    shared_examples 'error is raised' do
      specify do
        expect { described_class.call(instance, aliases) }
          .to raise_error(Surrealist::InvalidAliasesError, 'Aliases should be defined as a hash')
      end
    end

    context 'with array' do
      let(:aliases) { %w[it is an array] }

      it_behaves_like 'error is raised'
    end

    context 'with struct' do
      let(:aliases) { Struct.new(:a, :b) }

      it_behaves_like 'error is raised'
    end

    context 'with number' do
      let(:aliases) { 2 }

      it_behaves_like 'error is raised'
    end

    context 'with string' do
      let(:aliases) { 'aliases' }

      it_behaves_like 'error is raised'
    end
  end
end
