# frozen_string_literal: true

require 'json'
require_relative '../lib/surrealist'

class Human
  include Surrealist

  attr_reader :name, :lastname

  json_schema do
    {
      name: String,
      lastname: String,
      properties: {
        gender: String,
        age: Integer,
      },
      credit_card: {
        number: Integer,
        holder: String,
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

  def initialize(name, lastname)
    @name = name
    @lastname = lastname
  end

  def properties
    Properties.new('male', 42)
  end

  def full_name
    "#{name} #{lastname}"
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
  attr_reader :number, :holder

  def initialize(number:, holder:)
    @number = number
    @holder = holder
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
    it 'works' do
      expect(JSON.parse(Human.new('John', 'Doe').surrealize))
        .to eq('name' => 'John', 'lastname' => 'Doe', 'properties' => {
          'gender' => 'male', 'age' => 42
        }, 'credit_card' => {
          'number' => 1234, 'holder' => 'John Doe'
        }, 'children' => {
          'male' => { 'count' => 2 },
          'female' => { 'count' => 1 },
        })
    end
  end
end
