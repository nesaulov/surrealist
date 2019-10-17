# frozen_string_literal: true

require_relative 'builtin/types'

module Surrealist
  module TypeSystems
    # Surrealist's builtin type system.
    # Non-strict, as any type is nullable.
    # Does not support coercion.
    module Builtin
      class << self
        include Result::DSL

        # Checks if a given value is an instance of the specified type class or NilClass.
        #
        # @param [any] value to be type checked.
        # @param [Class] type class to be satisfied.
        #
        # @return [Result]
        def check_type(value, type_class)
          return success if type_class == Types::Any
          return success if value.nil?

          return check_bool(value) if type_class == Types::Bool

          if value.is_a?(type_class)
            success
          else
            failure("Expected #{type_class}, got #{value.class}")
          end
        end

        # The builtin type system does not support coercion.
        #
        # @param [any] value to be coerced.
        # @param [Class] type class to coerce the value to.
        #
        # @return [any]
        def coerce(value, _type_class)
          value
        end

        private

        def check_bool(value)
          return success if value == true
          return success if value == false

          failure("Expected Bool, got #{value.class}")
        end
      end
    end
  end
end
