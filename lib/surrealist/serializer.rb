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

    class << self
      # Defines instance methods that read values from the context hash.
      #
      # @param [Array<Symbol>] array
      #   an array of symbols which represent method names
      #
      # @raise ArgumentError if type of argument is not an array of symbols
      def serializer_context(*array)
        unless array.all? { |i| i.is_a? Symbol }
          raise ArgumentError, 'Please provide an array of symbols to `.serializer_context`'
        end

        array.each { |method| define_method(method) { context[method] } }
      end

      # Plural form ¯\_(ツ)_/¯
      alias serializer_contexts serializer_context
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
      if Helper.collection?(object)
        Surrealist.surrealize_collection(object, args.merge(context: context))
      else
        Surrealist.surrealize(instance: self, **args)
      end
    end

    # Passes build_schema to Surrealist
    def build_schema(**args)
      if Helper.collection?(object)
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
