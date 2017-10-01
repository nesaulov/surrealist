# frozen_string_literal: true

require 'surrealist/class_methods'
require 'surrealist/instance_methods'
require 'surrealist/bool'
require 'surrealist/any'
require 'surrealist/utils'
require 'surrealist/type_helper'
require 'json'

# Main module that provides the +json_schema+ class method and +surrealize+ instance method.
module Surrealist
  # Error class for classes without defined +schema+.
  class UnknownSchemaError < RuntimeError; end

  # Error class for classes with +json_schema+ defined not as a hash.
  class InvalidSchemaError < RuntimeError; end

  # Error class for +NoMethodError+.
  class UndefinedMethodError < RuntimeError; end

  # Error class for failed type-checks.
  class InvalidTypeError < TypeError; end

  # @param [Class] base class to include/extend +Surrealist+.
  def self.included(base)
    base.extend(Surrealist::ClassMethods)
    base.include(Surrealist::InstanceMethods)
  end

  # Dumps the object's methods corresponding to the schema
  # provided in the object's class and type-checks the values.
  #
  # @param [Object] instance of a class that has +Surrealist+ included.
  #
  # @return [String] a json-formatted string corresponding to the schema
  #   provided in the object's class. Values will be taken from the return values
  #   of appropriate methods from the object.
  #
  # @raise +Surrealist::UnknownSchemaError+ if no schema was provided in the object's class.
  #
  # @raise +Surrealist::InvalidTypeError+ if type-check failed at some point.
  #
  # @raise +Surrealist::UndefinedMethodError+ if a key defined in the schema
  #   does not have a corresponding method on the object.
  #
  # @example Define a schema and surrealize the object
  #   class User
  #     include Surrealist
  #
  #     json_schema do
  #       {
  #         name: String,
  #         age: Integer,
  #       }
  #     end
  #
  #     def name
  #       'Nikita'
  #     end
  #
  #     def age
  #       23
  #     end
  #   end
  #
  #   User.new.surrealize
  #   # => "{\"name\":\"Nikita\",\"age\":23}"
  #   # For more examples see README
  def self.surrealize(instance, camelize:)
    ::JSON.dump(build_schema(instance, camelize: camelize))
  end

  # Builds hash from schema provided in the object's class and type-checks the values.
  #
  # @param [Object] instance of a class that has +Surrealist+ included.
  #
  # @return [Hash] a hash corresponding to the schema
  #   provided in the object's class. Values will be taken from the return values
  #   of appropriate methods from the object.
  #
  # @raise +Surrealist::UnknownSchemaError+ if no schema was provided in the object's class.
  #
  # @raise +Surrealist::InvalidTypeError+ if type-check failed at some point.
  #
  # @raise +Surrealist::UndefinedMethodError+ if a key defined in the schema
  #   does not have a corresponding method on the object.
  #
  # @example Define a schema and surrealize the object
  #   class User
  #     include Surrealist
  #
  #     json_schema do
  #       {
  #         name: String,
  #         age: Integer,
  #       }
  #     end
  #
  #     def name
  #       'Nikita'
  #     end
  #
  #     def age
  #       23
  #     end
  #   end
  #
  #   User.new.build_schema
  #   # => { name: 'Nikita', age: 23 }
  #   # For more examples see README
  def self.build_schema(instance, camelize:)
    schema = instance.class.instance_variable_get('@__surrealist_schema')

    if schema.nil?
      raise Surrealist::UnknownSchemaError, "Can't serialize #{instance.class} - no schema was provided."
    end

    hash = Builder.call(schema: Surrealist::Utils.deep_copy(schema), instance: instance)

    camelize ? Surrealist::Utils.camelize_hash(hash) : hash
  end
end
