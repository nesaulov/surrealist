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
      weight:   Types::String,
      cat_food: {
        amount: Types::Strict::Int,
        brand:  Types::Strict::String,
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

RSpec.describe Surrealist do
  describe 'root option' do
    context 'nil root' do
      let(:instance) { Cat.new }

      it 'builds schema' do
        expect(instance.build_schema(root: nil)).to eq(cat_weight: '3 kilos')
      end

      it 'surrealizes' do
        expect(JSON.parse(instance.surrealize(root: nil)))
          .to eq('cat_weight' => '3 kilos')
      end

      it 'camelizes' do
        expect(instance.build_schema(root: nil, camelize: true))
          .to eq(catWeight: '3 kilos')

        expect(JSON.parse(instance.surrealize(root: nil, camelize: true)))
          .to eq('catWeight' => '3 kilos')
      end
    end

    context 'simple example' do
      let(:instance) { Cat.new }

      it 'builds schema' do
        expect(instance.build_schema(root: 'kitten')).to eq(kitten: { cat_weight: '3 kilos' })
      end

      it 'surrealizes' do
        expect(JSON.parse(instance.surrealize(root: 'kitten')))
          .to eq('kitten' => { 'cat_weight' => '3 kilos' })
      end

      it 'camelizes' do
        expect(instance.build_schema(root: 'kitten', camelize: true))
          .to eq(kitten: { catWeight: '3 kilos' })

        expect(JSON.parse(instance.surrealize(root: 'kitten', camelize: true)))
          .to eq('kitten' => { 'catWeight' => '3 kilos' })
      end

      it 'overrides include_root' do
        expect(JSON.parse(instance.surrealize(root: 'kitten', include_root: true)))
          .to eq('kitten' => { 'cat_weight' => '3 kilos' })
      end

      it 'overrides include_namespaces' do
        expect(JSON.parse(instance.surrealize(root: 'kitten', include_namespaces: true)))
          .to eq('kitten' => { 'cat_weight' => '3 kilos' })
      end
    end

    context 'simple example using a symbol' do
      let(:instance) { Cat.new }

      it 'builds schema' do
        expect(instance.build_schema(root: :kitten)).to eq(kitten: { cat_weight: '3 kilos' })
      end

      it 'surrealizes' do
        expect(JSON.parse(instance.surrealize(root: :kitten)))
          .to eq('kitten' => { 'cat_weight' => '3 kilos' })
      end

      it 'camelizes' do
        expect(instance.build_schema(root: :kitten, camelize: true))
          .to eq(kitten: { catWeight: '3 kilos' })

        expect(JSON.parse(instance.surrealize(root: :kitten, camelize: true)))
          .to eq('kitten' => { 'catWeight' => '3 kilos' })
      end

      it 'overrides include_root' do
        expect(JSON.parse(instance.surrealize(root: :kitten, include_root: true)))
          .to eq('kitten' => { 'cat_weight' => '3 kilos' })
      end

      it 'overrides include_namespaces' do
        expect(JSON.parse(instance.surrealize(root: :kitten, include_namespaces: true)))
          .to eq('kitten' => { 'cat_weight' => '3 kilos' })
      end
    end

    context 'with nested objects' do
      let(:instance) { SeriousCat.new }

      it 'builds schema' do
        expect(instance.build_schema(root: 'serious_kitten'))
          .to eq(serious_kitten: { weight: '3 kilos', cat_food: { amount: 3, brand: 'Whiskas' } })
      end

      it 'surrealizes' do
        expect(JSON.parse(instance.surrealize(root: 'serious_kitten')))
          .to eq('serious_kitten' => { 'weight'   => '3 kilos',
                                       'cat_food' => { 'amount' => 3, 'brand' => 'Whiskas' } })
      end

      it 'camelizes' do
        expect(instance.build_schema(root: 'serious_kitten', camelize: true))
          .to eq(seriousKitten: { weight: '3 kilos', catFood: { amount: 3, brand: 'Whiskas' } })

        expect(JSON.parse(instance.surrealize(root: 'serious_kitten', camelize: true)))
          .to eq('seriousKitten' => { 'weight'  => '3 kilos',
                                      'catFood' => { 'amount' => 3, 'brand' => 'Whiskas' } })
      end

      it 'overrides include_root' do
        expect(JSON.parse(instance.surrealize(root: 'serious_kitten', include_root: true)))
          .to eq('serious_kitten' => { 'weight'   => '3 kilos',
                                       'cat_food' => { 'amount' => 3,
                                                       'brand' => 'Whiskas' } })
      end

      it 'overrides include_namespaces' do
        expect(JSON.parse(instance.surrealize(root: 'serious_kitten', include_namespaces: true)))
          .to eq('serious_kitten' => { 'weight'   => '3 kilos',
                                       'cat_food' => { 'amount' => 3,
                                                       'brand' => 'Whiskas' } })
      end
    end

    context 'with nested classes' do
      let(:instance) { Animal::Dog.new }

      it 'builds schema' do
        expect(instance.build_schema(root: 'new_dog')).to eq(new_dog: { breed: 'Collie' })
      end

      it 'surrealizes' do
        expect(JSON.parse(instance.surrealize(root: 'new_dog')))
          .to eq('new_dog' => { 'breed' => 'Collie' })
      end

      it 'camelizes' do
        expect(instance.build_schema(root: 'newDog', camelize: true))
          .to eq(newDog: { breed: 'Collie' })

        expect(JSON.parse(instance.surrealize(root: 'new_dog', camelize: true)))
          .to eq('newDog' => { 'breed' => 'Collie' })
      end

      it 'overrides include_root' do
        expect(JSON.parse(instance.surrealize(root: 'new_dog', include_root: true)))
          .to eq('new_dog' => { 'breed' => 'Collie' })
      end

      it 'overrides include_namespaces' do
        expect(JSON.parse(instance.surrealize(root: 'new_dog', include_namespaces: true)))
          .to eq('new_dog' => { 'breed' => 'Collie' })
      end
    end

    context 'Module::Class' do
      let(:instance) { Instrument::Guitar.new }

      it 'builds schema' do
        expect(instance.build_schema(root: 'new_guitar'))
          .to eq(new_guitar: { brand_name: 'Fender' })
      end

      it 'surrealizes' do
        expect(JSON.parse(instance.surrealize(root: 'new_guitar')))
          .to eq('new_guitar' => { 'brand_name' => 'Fender' })
      end

      it 'camelizes' do
        expect(instance.build_schema(root: 'new_guitar', camelize: true))
          .to eq(newGuitar: { brandName: 'Fender' })

        expect(JSON.parse(instance.surrealize(root: 'new_guitar', camelize: true)))
          .to eq('newGuitar' => { 'brandName' => 'Fender' })
      end

      it 'overrides include_root' do
        expect(JSON.parse(instance.surrealize(root: 'new_guitar', include_root: true)))
          .to eq('new_guitar' => { 'brand_name' => 'Fender' })
      end

      it 'overrides include_namespaces' do
        expect(JSON.parse(instance.surrealize(root: 'new_guitar', include_namespaces: true)))
          .to eq('new_guitar' => { 'brand_name' => 'Fender' })
      end
    end

    context 'triple nesting' do
      let(:instance) { Code::Language::Ruby.new }

      it 'builds schema' do
        expect(instance.build_schema(root: 'new_ruby'))
          .to eq(new_ruby: { age: '22 years' })
      end

      it 'surrealizes' do
        expect(JSON.parse(instance.surrealize(root: 'new_ruby')))
          .to eq('new_ruby' => { 'age' => '22 years' })
      end

      it 'camelizes' do
        expect(instance.build_schema(root: 'new_ruby', camelize: true))
          .to eq(newRuby: { age: '22 years' })

        expect(JSON.parse(instance.surrealize(root: 'new_ruby', camelize: true)))
          .to eq('newRuby' => { 'age' => '22 years' })
      end

      it 'overrides include_root' do
        expect(JSON.parse(instance.surrealize(root: 'new_ruby', include_root: true)))
          .to eq('new_ruby' => { 'age' => '22 years' })
      end

      it 'overrides include_namespaces' do
        expect(JSON.parse(instance.surrealize(root: 'new_ruby', include_namespaces: true)))
          .to eq('new_ruby' => { 'age' => '22 years' })
      end
    end
  end
end
