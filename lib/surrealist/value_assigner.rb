# frozen_string_literal: true

module Surrealist
  # A class that determines the correct value to return for serialization. May descend recursively.
  class ValueAssigner
    class << self
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
      def assign(instance:, schema:)
        value = raw_value(instance: instance, schema: schema)

        # array to track and prevent infinite self references in surrealization
        @stack ||= []

        if value.respond_to?(:build_schema)
          yield assign_nested_record(instance: instance, value: value)
        elsif value.respond_to?(:each) && !value.empty? && value.all? { |v| Helper.surrealist?(v.class) }
          yield assign_nested_collection(instance: instance, value: value)
        else
          yield value
        end
      end

      private

      def raw_value(instance:, schema:)
        value = instance.is_a?(Hash) ? instance[schema.key] : instance.send(schema.key)
        unless TypeHelper.valid_type?(value: value, type: schema.value)
          raise Surrealist::InvalidTypeError,
                "Wrong type for key `#{schema.key}`. Expected #{schema.value}, got #{value.class}."
        end
        TypeHelper.coerce(type: schema.value, value: value)
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
