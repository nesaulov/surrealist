# frozen_string_literal: true

require_relative '../lib/surrealist'

class Human
  include Surrealist

  attr_reader :name, :last_name

  json_schema do
    {
      name: String,
      last_name: String,
      properties: {
        gender: String,
        age: Integer,
      },
      credit_card: {
        card_number: Integer,
        card_holder: String,
      },
      children: {
        male: {
          count: Integer,
        },
        female: {
          count: Integer,
        },
      },
    }
  end

  def initialize(name, last_name)
    @name = name
    @last_name = last_name
  end

  def properties
    Properties.new('male', 42)
  end

  def full_name
    "#{name} #{last_name}"
  end

  def credit_card
    CreditCard.new(number: 1234, holder: full_name)
  end

  def children
    Kid.find(person: 'John')
  end
end

Properties = Struct.new(:gender, :age)

class CreditCard
  attr_reader :card_number, :card_holder

  def initialize(number:, holder:)
    @card_number = number
    @card_holder = holder
  end
end

class Kid
  attr_reader :person

  def self.find(person:)
    new(person: person)
  end

  def initialize(person:)
    @person = person
  end

  def male
    person == 'John' ? { count: 2 } : { count: 1 }
  end

  def female
    person == 'John' ? { count: 1 } : { count: 2 }
  end
end

RSpec.describe Surrealist do
  context 'ultimate spec' do
    let(:human) { Human.new('John', 'Doe') }

    it 'surrealizes' do
      expect(JSON.parse(human.surrealize))
        .to eq('name' => 'John', 'last_name' => 'Doe', 'properties' => {
          'gender' => 'male', 'age' => 42
        }, 'credit_card' => {
          'card_number' => 1234, 'card_holder' => 'John Doe'
        }, 'children' => {
          'male' => { 'count' => 2 },
          'female' => { 'count' => 1 },
        })
    end

    it 'builds schema' do
      expect(human.build_schema)
        .to eq(name: 'John', last_name: 'Doe', properties: { gender: 'male', age: 42 },
               credit_card: { card_number: 1234, card_holder: 'John Doe' },
               children: { male: { count: 2 }, female: { count: 1 } })
    end

    it 'camelizes' do
      expect(JSON.parse(human.surrealize(camelize: true)))
        .to eq('name' => 'John', 'lastName' => 'Doe', 'properties' => {
          'gender' => 'male', 'age' => 42
        }, 'creditCard' => {
          'cardNumber' => 1234, 'cardHolder' => 'John Doe'
        }, 'children' => {
          'male' => { 'count' => 2 },
          'female' => { 'count' => 1 },
        })

      expect(human.build_schema(camelize: true))
        .to eq(name: 'John', lastName: 'Doe', properties: { gender: 'male', age: 42 },
               creditCard: { cardNumber: 1234, cardHolder: 'John Doe' },
               children: { male: { count: 2 }, female: { count: 1 } })
    end

    it 'includes root' do
      expect(JSON.parse(human.surrealize(camelize: true, include_root: true)))
        .to eq('human' => {
          'name'          => 'John', 'lastName' => 'Doe', 'properties' => {
            'gender' => 'male', 'age' => 42
          }, 'creditCard' => {
            'cardNumber' => 1234, 'cardHolder' => 'John Doe'
          }, 'children'   => {
            'male'   => { 'count' => 2 },
            'female' => { 'count' => 1 },
          }
        })

      expect(human.build_schema(camelize: true, include_root: true))
        .to eq(human: {
          name: 'John', lastName: 'Doe', properties: { gender: 'male', age: 42 },
          creditCard: { cardNumber: 1234, cardHolder: 'John Doe' },
          children:   { male: { count: 2 }, female: { count: 1 } }
        })
    end
  end
end
