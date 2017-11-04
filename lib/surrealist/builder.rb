# frozen_string_literal: true

module Surrealist
  # A class that builds a hash from the schema and type-checks the values.
  class Builder
    class << self
      Schema = Struct.new(:key, :value).freeze
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
            check_for_ar(schema, instance, schema_key, schema_value)
          else
            ValueAssigner.assign(schema:   Schema.new(schema_key, schema_value),
                                 instance: instance) { |coerced_value| schema[schema_key] = coerced_value }
          end
        end
      rescue NoMethodError => e
        raise Surrealist::UndefinedMethodError,
              "#{e.message}. You have probably defined a key " \
              "in the schema that doesn't have a corresponding method."
      end

      private

      def check_for_ar(schema, instance, key, value)
        if ar_collection?(instance, key)
          construct_collection(schema, instance, key, value)
        else
          Builder.call(schema: value,
                       instance: instance.respond_to?(key) ? instance.send(key) : instance)
        end
      end

      def ar_collection?(instance, schema_key)
        defined?(ActiveRecord) &&
          instance.respond_to?(schema_key) &&
          instance.send(schema_key).is_a?(ActiveRecord::Relation)
      end

      def construct_collection(schema, instance, schema_key, schema_value)
        schema[schema_key] = []
        instance.send(schema_key).each do |i|
          schema[schema_key] << call(
            schema:   Copier.deep_copy(hash: schema_value, carrier: Surrealist::NULL_CARRIER),
            instance: i,
          )
        end
      end
    end
  end
end
