# frozen_string_literal: true

module Surrealist
  # Error class for classes without defined +schema+.
  class UnknownSchemaError < RuntimeError; end

  # Error class for classes with +json_schema+ defined not as a hash.
  class InvalidSchemaError < RuntimeError; end

  # Error class for +NoMethodError+.
  class UndefinedMethodError < RuntimeError; end

  # Error class for failed type-checks.
  class InvalidTypeError < TypeError; end

  # Error class for undefined root keys for schema wrapping.
  class UnknownRootError < RuntimeError; end

  # Error class for undefined class to delegate schema.
  class InvalidSchemaDelegation < RuntimeError; end

  # Error class for invalid object given to iteratively apply surrealize.
  class InvalidCollectionError < ArgumentError; end

  class ExceptionRaiser
    class << self
      # Raises Surrealist::InvalidSchemaDelegation if destination of delegation does not
      # include Surrealist.
      #
      # @raise Surrealist::InvalidSchemaDelegation
      def raise_invalid_schema_delegation!
        raise Surrealist::InvalidSchemaDelegation, 'Class does not include Surrealist'
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
        raise Surrealist::UnknownRootError, "Can't wrap schema in root key - class name was not passed"
      end

      # Raises Surrealist::InvalidCollectionError
      #
      # @raise Surrealist::InvalidCollectionError
      def raise_invalid_collection!
        raise Surrealist::InvalidCollectionError, "Can't serialize collection - must respond to :each"
      end
    end
  end
end
