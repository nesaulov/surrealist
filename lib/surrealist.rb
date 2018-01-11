# frozen_string_literal: true

require 'json'
require_relative 'surrealist/any'
require_relative 'surrealist/bool'
require_relative 'surrealist/builder'
require_relative 'surrealist/carrier'
require_relative 'surrealist/class_methods'
require_relative 'surrealist/copier'
require_relative 'surrealist/exception_raiser'
require_relative 'surrealist/hash_utils'
require_relative 'surrealist/helper'
require_relative 'surrealist/instance_methods'
require_relative 'surrealist/schema_definer'
require_relative 'surrealist/serializer'
require_relative 'surrealist/string_utils'
require_relative 'surrealist/type_helper'
require_relative 'surrealist/value_assigner'
require_relative 'surrealist/vars_helper'

# Main module that provides the +json_schema+ class method and +surrealize+ instance method.
module Surrealist
  # Default namespaces nesting level
  DEFAULT_NESTING_LEVEL = 666

  class << self
    # @param [Class] base class to include/extend +Surrealist+.
    def included(base)
      base.extend(Surrealist::ClassMethods)
      base.include(Surrealist::InstanceMethods)
    end

    # Iterates over a collection of Surrealist Objects and
    # maps surrealize to each object.
    #
    # @param [Object] collection of instances of a class that has +Surrealist+ included.
    # @param [Boolean] [optional] camelize optional argument for converting hash to camelBack.
    # @param [Boolean] [optional] include_root optional argument for having the root key of the resulting hash
    #   as instance's class name.
    # @param [Boolean] [optional] include_namespaces optional argument for having root key as a nested hash of
    #   instance's namespaces. Animal::Cat.new.surrealize -> (animal: { cat: { weight: '3 kilos' } })
    # @param [String] [optional] root optional argument for using a specified root key for the hash.
    # @param [Integer] [optional] namespaces_nesting_level level of namespaces nesting.
    # @param [Boolean] [optional] raw optional argument for specifying the expected output format.
    #
    # @return [JSON | Hash] the Collection#map with elements being json-formatted string corresponding
    #   to the schema provided in the object's class. Values will be taken from the return values
    #   of appropriate methods from the object.
    #
    # @raise +Surrealist::InvalidCollectionError+ if invalid collection passed.
    #
    # @example surrealize a given collection of Surrealist objects
    #   Surrealist.surrealize_collection(User.all)
    #   # => "[{\"name\":\"Nikita\",\"age\":23}, {\"name\":\"Alessandro\",\"age\":24}]"
    #   # For more examples see README
    def surrealize_collection(collection, **args)
      raise Surrealist::ExceptionRaiser.raise_invalid_collection! unless collection.respond_to?(:each)

      result = collection.map do |object|
        Helper.surrealist?(object.class) ? __build_schema(object, args) : object
      end

      args[:raw] ? result : JSON.dump(result)
    end

    # Dumps the object's methods corresponding to the schema
    # provided in the object's class and type-checks the values.
    #
    # @param [Boolean] [optional] camelize optional argument for converting hash to camelBack.
    # @param [Boolean] [optional] include_root optional argument for having the root key of the resulting hash
    #   as instance's class name.
    # @param [Boolean] [optional] include_namespaces optional argument for having root key as a nested hash of
    #   instance's namespaces. Animal::Cat.new.surrealize -> (animal: { cat: { weight: '3 kilos' } })
    # @param [String] [optional] root optional argument for using a specified root key for the hash
    # @param [Integer] [optional] namespaces_nesting_level level of namespaces nesting.
    #
    # @return [String] a json-formatted string corresponding to the schema
    #   provided in the object's class. Values will be taken from the return values
    #   of appropriate methods from the object.
    def surrealize(instance:, **args)
      JSON.dump(build_schema(instance: instance, **args))
    end

    # Builds hash from schema provided in the object's class and type-checks the values.
    #
    # @param [Object] instance of a class that has +Surrealist+ included.
    # @param [Hash] args optional arguments
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
    def build_schema(instance:, **args)
      carrier = Surrealist::Carrier.call(args)
      schema = Surrealist::VarsHelper.find_schema(instance.class)

      Surrealist::ExceptionRaiser.raise_unknown_schema!(instance) if schema.nil?

      normalized_schema = Surrealist::Copier.deep_copy(
        hash:    schema,
        klass:   instance.class.name,
        carrier: carrier,
      )

      hash = Builder.new(carrier: carrier, schema: normalized_schema, instance: instance).call
      carrier.camelize ? Surrealist::HashUtils.camelize_hash(hash) : hash
    end

    private

    # Checks if there is a serializer (< Surrealist::Serializer) defined for the object and delegates
    # surrealization to it.
    #
    # @param [Object] object serializable object
    # @param [Hash] args optional arguments passed to +surrealize_collection+
    #
    # @return [Hash] a hash corresponding to the schema
    #   provided in the object's class. Values will be taken from the return values
    #   of appropriate methods from the object.
    def __build_schema(object, **args)
      if (serializer = Surrealist::VarsHelper.find_serializer(object.class))
        serializer.new(object, args[:context].to_h).build_schema(args)
      else
        build_schema(instance: object, **args)
      end
    end
  end
end
