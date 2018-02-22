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

    def self.serializer_context(*array)
      raise 'Please provide an array of symbols to `.serializer_context`' unless array.is_a?(Array)

      array.uniq.compact.each do |method|
        define_method method.to_sym do
          context[method]
        end
      end
    end

    # NOTE: #context will work only when using serializer explicitly,
    #   e.g `CatSerializer.new(Cat.new(3), food: CatFood.new)`
    #   And then food will be available inside serializer via `context[:food]`
    def initialize(object, **context)
      @object = object
      @context = context
    end

    # Checks whether object is a collection or an instance and serializes it
    def surrealize(**args)
      if object.respond_to?(:each)
        Surrealist.surrealize_collection(object, args.merge(context: context))
      else
        Surrealist.surrealize(instance: self, **args)
      end
    end

    # Passes build_schema to Surrealist
    def build_schema(**args)
      if object.respond_to?(:each)
        build_collection_schema(args)
      else
        Surrealist.build_schema(instance: self, **args)
      end
    end

    private

    attr_reader :object, :context

    # Maps collection and builds schema for each instance.
    def build_collection_schema(**args)
      object.map { |object| self.class.new(object, context).build_schema(args) }
    end

    # Methods not found inside serializer will be invoked on the object
    def method_missing(method, *args, &block)
      object.public_send(method, *args, &block)
    end

    # Methods not found inside serializer will be invoked on the object
    def respond_to_missing?(method, include_private = false)
      object.respond_to?(method) || super
    end
  end
end
