# frozen_string_literal: true

module Surrealist
  # Class methods that are extended by the object.
  module ClassMethods
    # A DSL method to define schema in a declarative style. Schema should be defined with a block
    # that contains a hash.
    # Every key of the schema should be either a name of a method of the
    # surrealizable object (or it's parents/mixins), or - in case value is a hash - a symbol:
    # to build nested JSON structures. Every value of the hash should be a constant that represents
    # a Ruby class, that will be used for type-checks.
    #
    # @param [Proc] _block that contains hash defining the schema
    #
    # @example DSL usage example
    #   class User
    #     include Surrealist
    #
    #     json_schema do
    #       {
    #         foo: String,
    #         bar: Integer,
    #       }
    #     end
    #
    #     def foo; 'A string'; end
    #     def bar; 42; end
    #   end
    #
    #   User.new.surrealize
    #   # => "{\"foo\":\"A string\",\"bar\":42}"
    #   # For more examples see README
    #
    # @example Schema with nested structure
    #   class Person
    #     include Surrealist
    #
    #     json_schema do
    #       {
    #         foo: String,
    #         nested: {
    #           bar: Integer,
    #         }
    #       }
    #     end
    #
    #     def foo; 'A string'; end
    #     def bar; 42; end
    #   end
    #
    #   Person.new.surrealize
    #   # => "{\"foo\":\"A string\",\"nested\":{\"bar\":42}}"
    #   # For more examples see README
    def json_schema(&_block)
      SchemaDefiner.call(self, yield)
    end

    # A DSL method to return the defined schema.
    # @example DSL usage example
    #   class Person
    #     include Surrealist
    #
    #     json_schema do
    #       { name: String }
    #     end
    #
    #     def name
    #       'Parent'
    #     end
    #   end
    #
    #   Person.defined_schema
    #   # => { name: String }
    def defined_schema
      read_schema.tap do |schema|
        raise UnknownSchemaError if schema.nil?
      end
    end

    # A DSL method to delegate schema in a declarative style. Must reference a valid
    # class that includes Surrealist
    #
    # @param [Class] klass
    #
    # @example DSL usage example
    #   class Host
    #     include Surrealist
    #
    #     json_schema do
    #       { name: String }
    #     end
    #
    #     def name
    #       'Parent'
    #     end
    #   end
    #
    #   class Guest < Host
    #     delegate_surrealization_to Host
    #
    #     def name
    #       'Child'
    #     end
    #   end
    #
    #   Guest.new.surrealize
    #   # => "{\"name\":\"Child\"}"
    #   # For more examples see README
    def delegate_surrealization_to(klass)
      raise TypeError, "Expected type of Class got #{klass.class} instead" unless klass.is_a?(Class)

      Surrealist::ExceptionRaiser.raise_invalid_schema_delegation! unless Helper.surrealist?(klass)

      hash = Surrealist::VarsHelper.find_schema(klass)
      Surrealist::VarsHelper.set_schema(self, hash)
    end

    # A DSL method for defining a class that holds serialization logic.
    #
    # @param [Class] klass a class that should inherit form Surrealist::Serializer
    #
    # @raise ArgumentError if Surrealist::Serializer is not found in the ancestors chain
    def surrealize_with(klass, tag: Surrealist::VarsHelper::DEFAULT_TAG)
      if klass < Surrealist::Serializer
        Surrealist::VarsHelper.add_serializer(self, klass, tag: tag)
        instance_variable_set(VarsHelper::PARENT_VARIABLE, klass.defined_schema)
      else
        raise ArgumentError, "#{klass} should be inherited from Surrealist::Serializer"
      end
    end

    # A DSL method for overriding a type system for a specific serializer.
    #
    # @param [Class] system the type system to use. Must conform to Surrealist's type system
    #   interface.
    def type_system(system)
      @type_system_override = system
    end
    attr_reader :type_system_override

    private

    def read_schema
      instance_variable_get(VarsHelper::INSTANCE_VARIABLE) ||
        instance_variable_get(VarsHelper::PARENT_VARIABLE)
    end
  end
end
