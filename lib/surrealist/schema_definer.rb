# frozen_string_literal: true

module Surrealist
  # A class that defines a method on the object that stores the schema.
  module SchemaDefiner
    SCHEMA_TYPE_ERROR = 'Schema should be defined as a hash'.freeze

    class << self
      # Defines an instance variable on the object that stores the schema.
      #
      # @param [Object] klass class of the object that needs to be surrealized.
      #
      # @param [Hash] hash the schema defined in the object's class.
      #
      # @return [Hash] +@__surrealist_schema+ variable that stores the schema of the object.
      #
      # @raise +Surrealist::InvalidSchemaError+ if schema was defined not through a hash.
      def call(klass, hash)
        raise Surrealist::InvalidSchemaError, SCHEMA_TYPE_ERROR unless hash.is_a?(Hash)

        Surrealist::VarsHelper.set_schema(klass, hash)
        define_missing_methods(klass, hash) if klass < Surrealist::Serializer
      end

      private

      # Defines all methods from the json_schema on Serializer instance in order to increase
      # performance (comparing to using method_missing)
      #
      # @param [Object] klass class of the object where methods will be defined
      #
      # @param [Hash] hash the schema hash
      def define_missing_methods(klass, hash)
        methods = find_methods(hash)
        klass.include(Module.new do
          instance_exec do
            methods.each do |method|
              define_method method do
                if (object = instance_variable_get('@object'))
                  object.public_send(method)
                end
              end
            end
          end
        end)
      end

      # Takes out all keys from a hash
      #
      # @param [Hash] hash a hash to take keys from
      #
      # @return [Array] an array of keys
      def find_methods(hash)
        hash.each_with_object([]) do |(k, v), keys|
          keys << k
          keys.concat(find_methods(v)) if v.is_a? Hash
        end
      end
    end
  end
end
