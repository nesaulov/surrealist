# frozen_string_literal: true

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
      },
    }
  end

  def weight
    '3 kilos'
  end

  def cat_food
    Struct.new(:amount, :brand).new(3, 'Whiskas')
  end
end

class Animal
  class Dog
    include Surrealist

    json_schema do
      { breed: String }
    end

    def breed
      'Collie'
    end
  end
end

module Instrument
  class Guitar
    include Surrealist

    json_schema do
      { brand_name: Types::Strict::String }
    end

    def brand_name
      'Fender'
    end
  end
end

class Code
  class Language
    class Ruby
      include Surrealist

      json_schema do
        { age: Types::String }
      end

      def age
        '22 years'
      end
    end
  end
end

class Matryoshka
  include Surrealist

  json_schema do
    { matryoshka: Integer, color: String }
  end

  def matryoshka
    10
  end

  def color
    'blue'
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
                                    'cat_food' => { 'amount' => 3, 'brand' => 'Whiskas' } })
      end

      it 'camelizes' do
        expect(instance.build_schema(include_root: true, camelize: true))
          .to eq(seriousCat: { weight: '3 kilos', catFood: { amount: 3, brand: 'Whiskas' } })

        expect(JSON.parse(instance.surrealize(include_root: true, camelize: true)))
          .to eq('seriousCat' => { 'weight' => '3 kilos',
                                   'catFood' => { 'amount' => 3, 'brand' => 'Whiskas' } })
      end
    end

    context 'with nested classes' do
      let(:instance) { Animal::Dog.new }

      it 'builds schema' do
        expect(instance.build_schema(include_root: true)).to eq(dog: { breed: 'Collie' })
      end

      it 'surrealizes' do
        expect(JSON.parse(instance.surrealize(include_root: true)))
          .to eq('dog' => { 'breed' => 'Collie' })
      end

      it 'camelizes' do
        expect(instance.build_schema(include_root: true, camelize: true))
          .to eq(dog: { breed: 'Collie' })

        expect(JSON.parse(instance.surrealize(include_root: true, camelize: true)))
          .to eq('dog' => { 'breed' => 'Collie' })
      end
    end

    context 'Module::Class' do
      let(:instance) { Instrument::Guitar.new }

      it 'builds schema' do
        expect(instance.build_schema(include_root: true))
          .to eq(guitar: { brand_name: 'Fender' })
      end

      it 'surrealizes' do
        expect(JSON.parse(instance.surrealize(include_root: true)))
          .to eq('guitar' => { 'brand_name' => 'Fender' })
      end

      it 'camelizes' do
        expect(instance.build_schema(include_root: true, camelize: true))
          .to eq(guitar: { brandName: 'Fender' })

        expect(JSON.parse(instance.surrealize(include_root: true, camelize: true)))
          .to eq('guitar' => { 'brandName' => 'Fender' })
      end
    end

    context 'triple nesting' do
      let(:instance) { Code::Language::Ruby.new }

      it 'builds schema' do
        expect(instance.build_schema(include_root: true))
          .to eq(ruby: { age: '22 years' })
      end

      it 'surrealizes' do
        expect(JSON.parse(instance.surrealize(include_root: true)))
          .to eq('ruby' => { 'age' => '22 years' })
      end

      it 'camelizes' do
        expect(instance.build_schema(include_root: true, camelize: true))
          .to eq(ruby: { age: '22 years' })

        expect(JSON.parse(instance.surrealize(include_root: true, camelize: true)))
          .to eq('ruby' => { 'age' => '22 years' })
      end
    end

    context 'root with same name as one of props' do
      let(:instance) { Matryoshka.new }

      it 'builds schema' do
        expect(instance.build_schema(include_root: true))
          .to eq(matryoshka: { matryoshka: 10, color: 'blue' })
      end

      it 'surrealizes' do
        expect(JSON.parse(instance.surrealize(include_root: true)))
          .to eq('matryoshka' => { 'matryoshka' => 10, 'color' => 'blue' })
      end

      it 'camelizes' do
        expect(instance.build_schema(include_root: true, camelize: true))
          .to eq(matryoshka: { matryoshka: 10, color: 'blue' })

        expect(JSON.parse(instance.surrealize(include_root: true, camelize: true)))
          .to eq('matryoshka' => { 'matryoshka' => 10, 'color' => 'blue' })
      end
    end
  end
end
