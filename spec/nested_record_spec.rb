# frozen_string_literal: true

require_relative '../lib/surrealist'
require_relative './orms/ar'
require_relative './carriers/params'

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

    context 'nested collection of objects to surrealize' do
      let(:subject) { Answer.first.question.build_schema }

      it 'works' do
        expect(subject.fetch(:answers)).to be_a Array
        expect(subject.fetch(:answers)[0].fetch(:question)).to be_nil
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

      context 'has associations' do
        it 'works' do
          expect(Surrealist.surrealize_collection(Employee.all))
            .not_to include('Manager')
        end
      end
    end

    it 'works with valid surrealization params' do
      VALID_PARAMS.each do |i|
        expect { Employee.first.build_schema(**i) }
          .to_not raise_error
      end
    end

    it 'fails with invalid surrealization params' do
      INVALID_PARAMS.each do |i|
        expect { Employee.first.build_schema(**i) }
          .to raise_error ArgumentError
      end
    end
  end
end
