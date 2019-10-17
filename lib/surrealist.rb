# frozen_string_literal: true

require 'oj'
require 'set'
require_relative 'surrealist/builder'
require_relative 'surrealist/class_methods'
require_relative 'surrealist/copier'
require_relative 'surrealist/exception_raiser'
require_relative 'surrealist/hash_utils'
require_relative 'surrealist/helper'
require_relative 'surrealist/instance_methods'
require_relative 'surrealist/schema_definer'
require_relative 'surrealist/serializer'
require_relative 'surrealist/string_utils'
require_relative 'surrealist/result'
require_relative 'surrealist/type_systems'
require_relative 'surrealist/value_assigner'
require_relative 'surrealist/vars_helper'
require_relative 'surrealist/wrapper'
require_relative 'surrealist/configuration'

# Main module that provides the +json_schema+ class method and +surrealize+ instance method.
module Surrealist
  # Default namespaces nesting level
  DEFAULT_NESTING_LEVEL = Configuration::DEFAULT_NESTING_LEVEL
  # Expose Surrealist's builtin type system's types
  Any = TypeSystems::Builtin::Types::Any
  Bool = TypeSystems::Builtin::Types::Bool

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
      Surrealist::ExceptionRaiser.raise_invalid_collection! unless Helper.collection?(collection)

      result = collection.map do |object|
        Helper.surrealist?(object.class) ? __build_schema(object, args) : object
      end

      args[:raw] ? result : Oj.dump(result, mode: :compat)
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
      Oj.dump(build_schema(instance: instance, **args), mode: :compat)
    end

    # rubocop:disable Metrics/AbcSize

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
      schema = Surrealist::VarsHelper.find_schema(instance.class)
      Surrealist::ExceptionRaiser.raise_unknown_schema!(instance) if schema.nil?

      unless instance.class.type_system_override.nil?
        args.merge!(type_system: instance.class.type_system_override)
      end

      overridden_config = config.with_overrides(args)

      # TODO: Refactor (something pipeline-like would do here, perhaps a builder of some sort)
      copied_schema = Surrealist::Copier.deep_copy(schema)
      built_schema = Builder.new(overridden_config, copied_schema, instance).call
      wrapped_schema = Surrealist::Wrapper.wrap(built_schema, overridden_config, instance.class.name)
      overridden_config.camelize? ? Surrealist::HashUtils.camelize_hash(wrapped_schema) : wrapped_schema
    end
    # rubocop:enable Metrics/AbcSize

    # Reads current default serialization arguments.
    #
    # @return [Hash] default arguments (@see Surrealist::Carrier)
    def config
      @config || Configuration::DEFAULT
    end

    # Sets default serialization arguments with a block
    #
    # @param [Hash] hash of arguments to be set (@see Surrealist::Carrier)
    # @param [Proc] _block a block which will be yielded to Surrealist::Carrier instance
    #
    # @example set config
    #   Surrealist.configure do |config|
    #     config.camelize = true
    #     config.include_root = true
    #   end
    #
    # rubocop:disable Metrics/MethodLength
    def configure(config = nil, &_block)
      if block_given?
        Configuration.new.tap do |config_instance|
          yield config_instance
          @config = config_instance
        end
      else
        @config =
          if config.nil?
            Configuration::DEFAULT
          elsif config.is_a?(Hash)
            Configuration.new(config)
          elsif config.is_a?(Configuration)
            config
          else
            raise ArgumentError, <<~MSG.squish
              Expected `config` to be a hash, nil, or an instance of Surrealist::Configuration,
              but got: #{config}
            MSG
          end
      end
    end
    # rubocop:enable Metrics/MethodLength

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
      return args[:serializer].new(object, args[:context].to_h).build_schema(args) if args[:serializer]

      if (serializer = Surrealist::VarsHelper.find_serializer(object.class, tag: args[:for]))
        serializer.new(object, args[:context].to_h).build_schema(args)
      else
        build_schema(instance: object, **args)
      end
    end
  end
end
