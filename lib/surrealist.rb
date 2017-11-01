# frozen_string_literal: true

require 'surrealist/any'
require 'surrealist/bool'
require 'surrealist/builder'
require 'surrealist/carrier'
require 'surrealist/class_methods'
require 'surrealist/copier'
require 'surrealist/exception_raiser'
require 'surrealist/hash_utils'
require 'surrealist/instance_methods'
require 'surrealist/schema_definer'
require 'surrealist/string_utils'
require 'surrealist/helper'
require 'surrealist/type_helper'
require 'surrealist/value_assigner'
require 'json'

# Main module that provides the +json_schema+ class method and +surrealize+ instance method.
module Surrealist
  # Default namespaces nesting level
  DEFAULT_NESTING_LEVEL = 666
  # Instance variable name that is set by SchemaDefiner
  INSTANCE_VARIABLE = '@__surrealist_schema'.freeze
  # Instance's parent instance variable name that is set by SchemaDefiner
  PARENT_VARIABLE = '@__surrealist_schema_parent'.freeze
  # Class variable name that is set by SchemaDefiner
  CLASS_VARIABLE = '@@__surrealist_schema'.freeze

  class << self
    # @param [Class] base class to include/extend +Surrealist+.
    def included(base)
      base.extend(Surrealist::ClassMethods)
      base.include(Surrealist::InstanceMethods)
    end

    # Iterates over a collection of Surrealist Objects and
    # maps surrealize to each record.
    #
    # @param [Object] collection of instances of a class that has +Surrealist+ included.
    # @param [Boolean] camelize optional argument for converting hash to camelBack.
    # @param [Boolean] include_root optional argument for having the root key of the resulting hash
    #   as instance's class name.
    # @param [String] root optional argument for using a specified root key for the resulting hash
    #
    # @return [Object] the Collection#map with elements being json-formatted string corresponding
    #   to the schema provided in the object's class. Values will be taken from the return values
    #   of appropriate methods from the object.
    #
    # @raise +Surrealist::InvalidCollectionError+ if invalid collection passed.
    #
    # @example surrealize a given collection of Surrealist objects
    #   Surrealist.surrealize_collection(User.all)
    #   # => "[{\"name\":\"Nikita\",\"age\":23}, {\"name\":\"Alessandro\",\"age\":24}]"
    #   # For more examples see README
    def surrealize_collection(collection, camelize: false, include_root: false, include_namespaces: false, root: nil, namespaces_nesting_level: DEFAULT_NESTING_LEVEL, raw: false) # rubocop:disable Metrics/LineLength
      raise Surrealist::ExceptionRaiser.raise_invalid_collection! unless collection.respond_to?(:each)

      result = collection.map do |record|
        if Helper.surrealist?(record.class)
          record.build_schema(
            camelize: camelize,
            include_root: include_root,
            include_namespaces: include_namespaces,
            root: root,
            namespaces_nesting_level: namespaces_nesting_level,
          )
        else
          record
        end
      end

      raw ? result : JSON.dump(result)
    end

    # Builds hash from schema provided in the object's class and type-checks the values.
    #
    # @param [Object] instance of a class that has +Surrealist+ included.
    # @param [Object] carrier instance of Carrier class that carries arguments passed to +surrealize+
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
    def build_schema(instance:, carrier:)
      schema = find_schema(instance)

      Surrealist::ExceptionRaiser.raise_unknown_schema!(instance) if schema.nil?

      normalized_schema = Surrealist::Copier.deep_copy(
        hash:    schema,
        klass:   instance.class.name,
        carrier: carrier,
      )

      hash = Builder.call(schema: normalized_schema, instance: instance)
      carrier.camelize ? Surrealist::HashUtils.camelize_hash(hash) : hash
    end

    private

    def find_schema(instance)
      delegatee = instance.class.instance_variable_get(PARENT_VARIABLE)
      maybe_schema = (delegatee || instance.class).instance_variable_get(INSTANCE_VARIABLE)
      maybe_schema || (instance.class.class_variable_get(CLASS_VARIABLE) if klass_var_defined?(instance))
    end

    def klass_var_defined?(instance)
      instance.class.class_variable_defined?(CLASS_VARIABLE)
    end
  end
end
