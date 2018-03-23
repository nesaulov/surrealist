# frozen_string_literal: true

module Surrealist
  # A class that determines the correct value to return for serialization. May descend recursively.
  module ValueAssigner
    class << self
      # Assigns value returned from a method to a corresponding key in the schema hash.
      #
      # @param [Object] instance the instance of the object which methods from the schema are called on.
      # @param [Struct] schema containing a single schema key and value
      #
      # @return [Hash] schema
      def assign(schema, instance)
        value = raw_value(instance, schema)

        # set to track and prevent infinite self references in surrealization
        @skip_set ||= Set.new

        if value.respond_to?(:build_schema)
          yield assign_nested_record(instance, value)
        elsif Helper.collection?(value) && !value.empty? && value.all? { |v| Helper.surrealist?(v.class) }
          yield assign_nested_collection(instance, value)
        else
          yield value
        end
      end

      private

      # Generates first pass of serializing value, doing type check and coercion
      #
      # @param [Object] instance the instance of the object which methods from the schema are called on.
      # @param [Struct] schema containing a single schema key and value
      #
      # @return [Object] value to be further processed
      def raw_value(instance, schema)
        value = instance.is_a?(Hash) ? instance[schema.key] : instance.send(schema.key)
        coerce_value(value, schema)
      end

      # Coerces value if type check is passed
      #
      # @param [Object] value the value to be checked and coerced
      # @param [Struct] schema containing a single schema key and value
      #
      # @raise +Surrealist::InvalidTypeError+ if type-check failed at some point.
      #
      # @return [Object] value to be further processed
      def coerce_value(value, schema)
        unless TypeHelper.valid_type?(value, schema.value)
          raise Surrealist::InvalidTypeError,
                "Wrong type for key `#{schema.key}`. Expected #{schema.value}, got #{value.class}."
        end
        TypeHelper.coerce(value, schema.value)
      end

      # Assists in recursively generating schema for records while preventing infinite self-referencing
      #
      # @param [Object] instance the instance of the object which methods from the schema are called on.
      # @param [Object] value a value that has to be type-checked.
      #
      # @return [Array] of schemas
      def assign_nested_collection(instance, value)
        return if @skip_set.include?(value.first.class)
        with_skip_set(instance.class) { Surrealist.surrealize_collection(value, raw: true) }
      end

      # Assists in recursively generating schema for a record while preventing infinite self-referencing
      #
      # @param [Object] instance the instance of the object which methods from the schema are called on.
      # @param [Object] value a value that has to be type-checked.
      #
      # @return [Hash] schema
      def assign_nested_record(instance, value)
        return if @skip_set.include?(value.class)
        with_skip_set(instance.class) { value.build_schema }
      end

      # Run block with klass in skip set
      #
      # @param [Class] klass of current instance.
      #
      # @return [Object] block result
      def with_skip_set(klass)
        return yield if @skip_set.include?(klass)
        @skip_set.add(klass)
        result = yield
        @skip_set.delete(klass)
        result
      end
    end
  end
end
