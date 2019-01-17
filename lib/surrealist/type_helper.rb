# frozen_string_literal: true

module Surrealist
  # Service class for type checking
  module TypeHelper
    # Dry-types class matcher
    DRY_TYPE_CLASS = /Dry::Types/.freeze

    class << self
      # Checks if value returned from a method is an instance of type class specified
      # in schema or NilClass.
      #
      # @param [any] value value returned from a method.
      # @param [Class] type class representing data type.
      #
      # @return [boolean]
      def valid_type?(value, type)
        return true if type == Any

        if type == Bool
          Surrealist::Carrier::BOOLEANS.include?(value)
        elsif defined?(Dry::Types) && dry_type?(type)
          type.try(value).success?
        else
          value.nil? || value.is_a?(type)
        end
      end

      # Coerces value is it should be coerced
      #
      # @param [any] value value that will be coerced
      # @param [Class] type class representing data type
      #
      # @return [any] coerced value
      def coerce(value, type)
        return value unless dry_type?(type)
        return value if type.try(value).input == value

        type[value]
      end

      private

      # Checks if type is an instance of dry-type
      #
      # @param [Object] type type to be checked
      #
      # @return [Boolean] is type an instance of dry-type
      def dry_type?(type)
        if type.respond_to?(:primitive) || type.class.name.nil?
          true
        else
          type.class.name =~ DRY_TYPE_CLASS
        end
      end
    end
  end
end
