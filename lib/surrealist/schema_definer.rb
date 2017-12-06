# frozen_string_literal: true

module Surrealist
  # A class that defines a method on the object that stores the schema.
  module SchemaDefiner
    SCHEMA_TYPE_ERROR = 'Schema should be defined as a hash'.freeze
    # Defines an instance variable on the object that stores the schema.
    #
    # @param [Object] klass class of the object that needs to be surrealized.
    #
    # @param [Hash] hash the schema defined in the object's class.
    #
    # @return [Hash] +@__surrealist_schema+ variable that stores the schema of the object.
    #
    # @raise +Surrealist::InvalidSchemaError+ if schema was defined not through a hash.
    def self.call(klass, hash)
      raise Surrealist::InvalidSchemaError, SCHEMA_TYPE_ERROR unless hash.is_a?(Hash)

      Surrealist::VarsFinder.set_schema(klass, hash)
    end
  end
end
