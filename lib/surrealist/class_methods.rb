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

    # A DSL method to create aliases for json schema. Must reference a valid
    # class that includes Surrealist
    #
    # @param [Hash] aliases
    #
    # @example DSL usage example
    #   class Person
    #     include Surrealist
    #
    #     json_aliases avatar: :image
    #
    #     json_shema do
    #       { avatar: String }
    #     end
    #
    #     def image
    #       'http://image-host.com/image.jpg'
    #     end
    #   end
    #
    #   Person.new.surrealize
    #   # => "{\"avatar\": \"http://image-host.com/image.jpg\"}"
    def json_aliases(aliases)
      AliasesDefiner.call(self, aliases)
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

      instance_variable_set(Surrealist::PARENT_VARIABLE, klass)
    end
  end
end
