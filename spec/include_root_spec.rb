# frozen_string_literal: true

require_relative '../lib/surrealist'
require 'dry-types'

module Types
  include Dry::Types.module
end

class Cat
  include Surrealist

  json_schema do
    { cat_weight: String }
  end

  def cat_weight
    '3 kilos'
  end
end

class SeriousCat
  include Surrealist

  json_schema do
    {
      weight: Types::String,
      cat_food: {
        amount: Types::Strict::Int,
        brand: Types::Strict::String,
      }
    }
  end

  def weight
    '3 kilos'
  end

  def cat_food
    CatFood.new(amount: 3, brand: 'Whiskas')
  end
end

class CatFood
  attr_reader :amount, :brand

  def initialize(amount:, brand:)
    @amount = amount
    @brand = brand
  end
end

RSpec.describe Surrealist do
  describe 'include_root option' do
    context 'simple example' do
      let(:instance) { Cat.new }

      it 'builds schema' do
        expect(instance.build_schema(include_root: true)).to eq(cat: { cat_weight: '3 kilos' })
      end

      it 'surrealizes' do
        expect(JSON.parse(instance.surrealize(include_root: true)))
          .to eq('cat' => { 'cat_weight' => '3 kilos' })
      end

      it 'camelizes' do
        expect(instance.build_schema(include_root: true, camelize: true))
          .to eq(cat: { catWeight: '3 kilos' })

        expect(JSON.parse(instance.surrealize(include_root: true, camelize: true)))
          .to eq('cat' => { 'catWeight' => '3 kilos' })
      end
    end


    context 'with nested objects' do
      let(:instance) { SeriousCat.new }

      it 'builds schema' do
        expect(instance.build_schema(include_root: true))
          .to eq(serious_cat: { weight: '3 kilos', cat_food: { amount: 3, brand: 'Whiskas' } })
      end

      it 'surrealizes' do
        expect(JSON.parse(instance.surrealize(include_root: true)))
          .to eq('serious_cat' => { 'weight' => '3 kilos',
                                    'cat_food' => {'amount' => 3, 'brand' => 'Whiskas' } })
      end

      it 'camelizes' do
        expect(instance.build_schema(include_root: true, camelize: true))
          .to eq(seriousCat: { weight: '3 kilos', catFood: { amount: 3, brand: 'Whiskas' } })

        expect(JSON.parse(instance.surrealize(include_root: true, camelize: true)))
          .to eq('seriousCat' => { 'weight' => '3 kilos',
                                    'catFood' => {'amount' => 3, 'brand' => 'Whiskas' } })
      end
    end
  end
end
