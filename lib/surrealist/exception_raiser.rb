# frozen_string_literal: true

module Surrealist
  # Error class for classes without defined +schema+.
  class UnknownSchemaError < RuntimeError; end

  # Error class for classes with +json_schema+ defined not as a hash.
  class InvalidSchemaError < ArgumentError; end

  # Error class for +NoMethodError+.
  class UndefinedMethodError < ArgumentError; end

  # Error class for failed type-checks.
  class InvalidTypeError < TypeError; end

  # Error class for undefined root keys for schema wrapping.
  class UnknownRootError < ArgumentError; end

  # Error class for undefined class to delegate schema.
  class InvalidSchemaDelegation < ArgumentError; end

  # Error class for invalid object given to iteratively apply surrealize.
  class InvalidCollectionError < ArgumentError; end

  # Error class for cases where +namespaces_nesting_level+ is set to 0.
  class InvalidNestingLevel < ArgumentError; end

  # Error class for unknown tag passed
  class UnknownTagError < ArgumentError; end

  # A class that raises all Surrealist exceptions
  module ExceptionRaiser
    CLASS_NAME_NOT_PASSED           = "Can't wrap schema in root key - class name was not passed".freeze
    MUST_RESPOND_TO_EACH            = "Can't serialize collection - must respond to :each".freeze
    CLASS_DOESNT_INCLUDE_SURREALIST = 'Class does not include Surrealist'.freeze

    class << self
      # Raises Surrealist::InvalidSchemaDelegation if destination of delegation does not
      # include Surrealist.
      #
      # @raise Surrealist::InvalidSchemaDelegation
      def raise_invalid_schema_delegation!
        raise Surrealist::InvalidSchemaDelegation, CLASS_DOESNT_INCLUDE_SURREALIST
      end

      # Raises Surrealist::UnknownSchemaError
      #
      # @param [Object] instance instance of the class without schema defined.
      #
      # @raise Surrealist::UnknownSchemaError
      def raise_unknown_schema!(instance)
        raise Surrealist::UnknownSchemaError,
              "Can't serialize #{instance.class} - no schema was provided."
      end

      # Raises Surrealist::UnknownRootError if class's name is unknown.
      #
      # @raise Surrealist::UnknownRootError
      def raise_unknown_root!
        raise Surrealist::UnknownRootError, CLASS_NAME_NOT_PASSED
      end

      # Raises Surrealist::InvalidCollectionError
      #
      # @raise Surrealist::InvalidCollectionError
      def raise_invalid_collection!
        raise Surrealist::InvalidCollectionError, MUST_RESPOND_TO_EACH
      end

      # Raises ArgumentError if namespaces_nesting_level is not an integer.
      #
      # @raise ArgumentError
      def raise_invalid_nesting!(value)
        raise ArgumentError,
              "Expected `namespaces_nesting_level` to be a positive integer, got: #{value}"
      end

      # Raises ArgumentError if root is not nil, a non-empty string or symbol.
      #
      # @raise ArgumentError
      def raise_invalid_root!(value)
        raise ArgumentError,
              "Expected `root` to be nil, a non-empty string, or symbol, got: #{value}"
      end

      # Raises ArgumentError if a key defined in the schema does not have a corresponding
      # method on the object.
      #
      # @raise Surrealist::UndefinedMethodError
      def raise_invalid_key!(e)
        raise Surrealist::UndefinedMethodError,
              "#{e.message}. You have probably defined a key " \
              "in the schema that doesn't have a corresponding method."
      end

      # Raises ArgumentError if a tag has no corresponding serializer
      #
      # @param [String] tag Wrong tag
      #
      # @raise Surrealist::UnknownTagError
      def raise_unknown_tag!(tag)
        raise Surrealist::UnknownTagError,
              "The tag specified (#{tag}) has no corresponding serializer"
      end
    end
  end
end
