# frozen_string_literal: true

module Surrealist
  # Abstract class to be inherited from
  #
  # @example Usage
  #   class CatSerializer < Surrealist::Serializer
  #     json_schema { { age: Integer, age_group: String } }
  #
  #     def age_group
  #       age <= 5 ? 'kitten' : 'cat'
  #     end
  #   end
  #
  #   class Cat
  #     include Surrealist
  #     attr_reader :age
  #
  #     surrealize_with CatSerializer
  #
  #     def initialize(age)
  #       @age = age
  #     end
  #   end
  #
  #   Cat.new(12).surrealize # Checks for schema in CatSerializer (if .surrealize_with is stated)
  #   # => '{ "age": 12, "age_group": "cat" }'
  #
  #   CatSerializer.new(Cat.new(3)).surrealize # explicit usage of CatSerializer
  #   # => '{ "age": 3, "age_group": "kitten" }'
  class Serializer
    extend Surrealist::ClassMethods

    attr_reader :object

    def initialize(object)
      @object = object
    end

    # Checks whether object is a collection or an instance and serializes it
    def surrealize(**args)
      if object.respond_to?(:each)
        Surrealist.surrealize_collection(object, args)
      else
        Surrealist.surrealize(instance: self, **args)
      end
    end

    # Passes build_schema to Surrealist
    def build_schema(**args)
      Surrealist.build_schema(instance: self, **args)
    end

    private

    # Methods not found inside serializer will be invoked on the object
    def method_missing(method, *args, &block)
      object.public_send(method, *args, &block) || super
    end

    # Methods not found inside serializer will be invoked on the object
    def respond_to_missing?(method, include_private = false)
      object.respond_to?(method) || super
    end
  end
end
