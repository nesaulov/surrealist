# frozen_string_literal: true

module Surrealist
  module TypeSystems
    # Surrealist's bridge to Dry::Types.
    # Dry::Types support strict and coercible types.
    module DryTypes
      class << self
        include Result::DSL

        # Checks if a given value is an instance of the specified type class.
        #
        # @param [any] value to be type checked.
        # @param [Class] type class to be satisfied.
        #
        # @return [Result]
        def check_type(value, type_class)
          return success if type_class.try(value).success?

          failure("Expected #{type_class}, got #{value.class}")
        end

        # Coerces the value to conform to the given type class.
        #
        # @param [any] value to be coerced.
        # @param [Class] type class to coerce the value to.
        #
        # @return [any]
        def coerce(value, type_class)
          return value if type_class.try(value).input == value

          type_class[value]
        end
      end
    end
  end
end
