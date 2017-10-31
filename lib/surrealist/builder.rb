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
            Builder.call(schema: schema_value,
                         instance: instance.respond_to?(schema_key) ? instance.send(schema_key) : instance)
          else
            assign_value(instance: instance,
                         method: schema_key,
                         value: instance.is_a?(Hash) ? instance[schema_key] : instance.send(schema_key),
                         type: schema_value) { |coerced_value| schema[schema_key] = coerced_value }
          end
        end
      rescue NoMethodError => e
        raise Surrealist::UndefinedMethodError,
              "#{e.message}. You have probably defined a key " \
              "in the schema that doesn't have a corresponding method."
      end

      private

      # Assigns value returned from a method to a corresponding key in the schema hash.
      #
      # @param [Object] instance the instance of the object which methods from the schema are called on.
      # @param [Symbol] method a key from the schema hash representing a method on the instance.
      # @param [Object] value a value that has to be type-checked.
      # @param [Class] type class representing data type.
      #
      # @raise +Surrealist::InvalidTypeError+ if type-check failed at some point.
      #
      # @return [Hash] schema
      def assign_value(instance:, method:, value:, type:, &_block)
        if TypeHelper.valid_type?(value: value, type: type)
          value = TypeHelper.coerce(type: type, value: value)

          @stack ||= []

          if value.respond_to?(:build_schema)
            yield assign_nested_record(instance: instance, value: value)
          elsif value.respond_to?(:each) && value.any? { |v| Helper.surrealist?(v.class) }
            yield assign_nested_collection(instance: instance, value: value)
          else
            yield value
          end
        else
          raise Surrealist::InvalidTypeError,
                "Wrong type for key `#{method}`. Expected #{type}, got #{value.class}."
        end
      end

      # Assists in recursively generating schema for records while preventing infinite self-referencing
      #
      # @param [Object] instance the instance of the object which methods from the schema are called on.
      # @param [Object] value a value that has to be type-checked.
      #
      # @return [Array] of schemas
      def assign_nested_collection(instance:, value:)
        return if @stack.include?(value.first.class)
        @stack << instance.class << value.first.class
        result = Surrealist.surrealize_collection(value, raw: true)
        @stack.delete(instance.class)
        result
      end

      # Assists in recursively generating schema for a record while preventing infinite self-referencing
      #
      # @param [Object] instance the instance of the object which methods from the schema are called on.
      # @param [Object] value a value that has to be type-checked.
      #
      # @return [Hash] schema
      def assign_nested_record(instance:, value:)
        return if @stack.include?(value.class)
        @stack << instance.class
        result = value.build_schema
        @stack.delete(instance.class)
        result
      end
    end
  end
end
