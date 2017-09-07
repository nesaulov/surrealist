# frozen_string_literal: true

require_relative 'builder'
require_relative 'schema_definer'
require 'pry'

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
    #     schema do
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
    #     schema do
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
    def schema(&_block)
      SchemaDefiner.call(self, yield)
    end
  end
end
