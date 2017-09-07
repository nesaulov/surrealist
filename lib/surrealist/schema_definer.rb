# frozen_string_literal: true

module Surrealist
  # A class that defines a method on the object that stores the schema.
  class SchemaDefiner
    # Defines a method on the object that stores the schema.
    #
    # @param [Object] klass class of the object that needs to be surrealized.
    #
    # @param [Hash] hash the schema defined in the object's class.
    #
    # @return [Method] +__surrealist_schema+ method that stores the schema of the object.
    #
    # @raise +Surrealist::InvalidSchemaError+ if schema was defined not through a hash.
    def self.call(klass, hash)
      raise Surrealist::InvalidSchemaError, 'Schema should be defined as a hash' unless hash.is_a?(Hash)

      klass.instance_eval do
        define_method '__surrealist_schema' do
          hash
        end
      end
    end
  end
end
