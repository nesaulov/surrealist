# frozen_string_literal: true

module Surrealist
  # A class that builds a hash from the schema and type-checks the values.
  class Builder
    # Struct to carry schema along
    Schema = Struct.new(:key, :value).freeze

    # @param [Carrier] carrier instance of Surrealist::Carrier
    # @param [Hash] schema the schema defined in the object's class.
    # @param [Hash] aliases the aliases map defined in the object's class.
    # @param [Object] instance the instance of the object which methods from the schema are called on.
    def initialize(carrier:, schema:, aliases:, instance:)
      @carrier  = carrier
      @schema   = schema
      @aliases  = aliases
      @instance = instance
    end

    # A method that goes recursively through the schema hash, defines the values and type-checks them.
    #
    # @param [Hash] schema the schema defined in the object's class.
    # @param [Object] instance the instance of the object which methods from the schema are called on.
    #
    # @raise +Surrealist::UndefinedMethodError+ if a key defined in the schema
    #   does not have a corresponding method on the object.
    #
    # @return [Hash] a hash that will be dumped into JSON.
    def call(schema: @schema, aliases: @aliases, instance: @instance)
      schema.each do |schema_key, schema_value|
        if schema_value.is_a?(Hash)
          check_for_ar(schema, instance, schema_key, schema_value)
        else
          ValueAssigner.assign(schema:   Schema.new(find_right_key(aliases, schema_key), schema_value),
                               instance: instance) { |coerced_value| schema[schema_key] = coerced_value }
        end
      end
    rescue NoMethodError => e
      Surrealist::ExceptionRaiser.raise_invalid_key!(e)
    end

    private

    attr_reader :carrier, :instance, :schema

    # Checks if result is an instance of ActiveRecord::Relation
    #
    # @param [Hash] schema the schema defined in the object's class.
    # @param [Object] instance the instance of the object which methods from the schema are called on.
    # @param [Symbol] key the symbol that represents method on the instance
    # @param [Any] value returned when key is called on instance
    #
    # @return [Hash] the schema hash
    def check_for_ar(schema, instance, key, value)
      if ar_collection?(instance, key)
        construct_collection(schema, instance, key, value)
      else
        nested_instance = instance.respond_to?(key) ? instance.send(key) : instance
        call(schema: value,
             aliases: Surrealist::VarsFinder.find_aliases(nested_instance),
             instance: nested_instance)
      end
    end

    # Checks if the instance responds to the method and whether it returns an AR::Relation
    #
    # @param [Object] instance
    # @param [Symbol] method
    #
    # @return [Boolean]
    def ar_collection?(instance, method)
      defined?(ActiveRecord) &&
        instance.respond_to?(method) &&
        instance.send(method).is_a?(ActiveRecord::Relation)
    end

    # Makes the value of appropriate key of the schema an array and pushes in results of iterating through
    #   records and surrealizing them
    #
    # @param [Hash] schema the schema defined in the object's class.
    # @param [Object] instance the instance of the object which methods from the schema are called on.
    # @param [Symbol] key the symbol that represents method on the instance
    # @param [Any] value returned when key is called on instance
    #
    # @return [Hash] the schema hash
    def construct_collection(schema, instance, key, value)
      schema[key] = []
      instance.send(key).each do |i|
        schema[key] << call(
          schema:   Copier.deep_copy(hash: value, carrier: carrier),
          instance: i,
        )
      end
    end

    # Find right key for json value considering aliases
    #
    # @param [String] key Key defined in json_schema method
    #
    # @return [String] right schema key
    def find_right_key(aliases, key)
      aliases.fetch(key, key)
    end
  end
end
