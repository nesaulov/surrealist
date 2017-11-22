# frozen_string_literal: true

module Surrealist
  # A class that defines a method on the object that stores the schema.
  class SchemaDefiner
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
      raise Surrealist::InvalidSchemaError, 'Schema should be defined as a hash' unless hash.is_a?(Hash)

      if klass.name =~ /ROM::Struct/
        klass.class_variable_set('@@__surrealist_schema', hash)
      else
        klass.instance_variable_set('@__surrealist_schema', hash)
      end
    end
  end
end
