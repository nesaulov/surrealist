# frozen_string_literal: true

module Surrealist
  # A class that builds a hash from the schema and type-checks the values.
  class Builder
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
            ValueAssigner.assign(schema: Schema.new(schema_key, schema_value),
                                 instance: instance) { |coerced_value| schema[schema_key] = coerced_value }
          end
        end
      rescue NoMethodError => e
        raise Surrealist::UndefinedMethodError,
              "#{e.message}. You have probably defined a key " \
              "in the schema that doesn't have a corresponding method."
      end

      Schema = Struct.new(:key, :value)
    end
  end
end
