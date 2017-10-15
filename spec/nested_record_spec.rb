require_relative '../lib/surrealist'
require_relative './orms/ar'

RSpec.describe Surrealist do
  describe 'nested object surrealization' do
    context 'object that has self-referencing assocation to surrealize' do
      it 'works' do
        expect(Executive.first.build_schema.fetch(:assistant).fetch(:executive))
          .to be_nil
      end
    end

    context 'object that has self-referencing nested association to surrealize' do
      it 'works' do
        expect(PromKing.first.build_schema.fetch(:prom).fetch(:prom_couple).fetch(:prom_king))
          .to be_nil
      end
    end

    context 'object that has association to surrealize' do
      it 'works' do
        expect(Employee.first.build_schema.fetch(:manager).keys)
          .to include(:name)
      end
    end

    context 'collection of objects to surrealize' do
      context 'has self-referencing assocations' do
        let(:subject) { Surrealist.surrealize_collection(Executive.all) }

        it 'works' do
          expect(subject).to match(/"executive":null/)
          expect(subject).to match(/"assistant":\{.+?\}/)
        end
      end

      context 'has assocatiaions' do
        it 'works' do
          collection = Employee.all
          expect(Surrealist.surrealize_collection(collection))
            .not_to include('Manager')
        end
      end
    end
  end
end
