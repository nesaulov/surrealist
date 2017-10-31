# frozen_string_literal: true

module Surrealist
  # A class that builds a hash from the schema and type-checks the values.
  class Builder
    # TODO: refactor methods so they don't take so much arguments
    class << self
      # A method that goes recursively through the schema hash, defines the values and type-checks them.
      #
      # @param [Hash] schema the schema defined in the object's class.
      # @param [Object] instance the instance of the object which methods from the schema are called on.
      #
      # @raise +Surrealist::UndefinedMethodError+ if a key defined in the schema
      #   does not have a corresponding method on the object.
      #
      # @return [Hash] a hash that will be dumped into JSON.
      def call(schema:, instance:)
        schema.each do |schema_key, schema_value|
          if schema_value.is_a?(Hash)
            parse_hash(hash: schema_value, schema: schema, instance: instance, key: schema_key)
          else
            type = schema_value
            schema_value = instance.is_a?(Hash) ? instance[schema_key] : instance.send(schema_key)
            assign_value(method: schema_key, value: schema_value, type: type) do |coerced_value|
              schema[schema_key] = coerced_value
            end
          end
        end
      rescue NoMethodError => e
        raise Surrealist::UndefinedMethodError,
              "#{e.message}. You have probably defined a key " \
              "in the schema that doesn't have a corresponding method."
      end

      private

      # Checks if hash represents methods on the instance.
      #
      # @param [Hash] hash a value from the schema hash.
      # @param [Hash] schema the schema defined in the object's class.
      # @param [Object] instance the instance of the object which methods from the schema are called on.
      # @param [Symbol] key a key from the schema hash.
      #
      # @return [Hash] schema
      def parse_hash(hash:, schema:, instance:, key:)
        if instance.respond_to?(key)
          maybe_take_values_from_instance(instance: instance, method: key, hash: hash, schema: schema)
        else
          call(schema: hash, instance: instance)
        end
      end

      # Checks if object's method include schema keys.
      #
      # @param [Object] instance the instance of the object which methods from the schema are called on.
      # @param [Symbol] method a key from the schema hash representing a method on the instance.
      # @param [Hash] hash a value from the schema hash.
      # @param [Hash] schema the schema defined in the object's class.
      #
      # @return [Hash] schema
      def maybe_take_values_from_instance(instance:, method:, hash:, schema:)
        object = instance.send(method)

        hash.each do |key, value|
          if object.methods.include?(key)
            take_values_from_instance(instance: object, value: value, hash: hash, key: key,
                                      schema: schema, method: method)
          elsif object.respond_to?(:each)
            object.each do |item|
              take_values_from_instance(instance: item, value: value, hash: hash, key: key,
                                        schema: schema, method: method)
            end
          end
        end
      end

      # Invokes methods on the instance and puts return values into the schema hash.
      #
      # @param [Object] instance the instance of the object which methods from the schema are called on.
      # @param [Class | Hash] value either type of value or a hash.
      # @param [Hash] hash a value from the schema hash.
      # @param [Hash] schema the schema defined in the object's class.
      # @param [Symbol] method a key from the schema hash representing a method on the instance.
      #
      # @return [Hash] schema
      def take_values_from_instance(instance:, value:, hash:, key:, schema:, method:)
        result = instance.send(key)

        if value.is_a?(Hash)
          parse_hash(hash: value, schema: hash, instance: result, key: key)
        else
          type = value
          assign_value(method: key, value: result, type: type) do |coerced_value|
            schema[method] = schema[method].merge(key => coerced_value)
          end
        end
      end

      # Assigns value returned from a method to a corresponding key in the schema hash.
      #
      # @param [Symbol] method a key from the schema hash representing a method on the instance.
      # @param [Object] value a value that has to be type-checked.
      # @param [Class] type class representing data type.
      #
      # @raise +Surrealist::InvalidTypeError+ if type-check failed at some point.
      #
      # @return [Hash] schema
      def assign_value(method:, value:, type:, &_block)
        if TypeHelper.valid_type?(value: value, type: type)
          value = TypeHelper.coerce(type: type, value: value)
          yield value
        else
          raise Surrealist::InvalidTypeError,
                "Wrong type for key `#{method}`. Expected #{type}, got #{value.class}."
        end
      end
    end
  end
end
