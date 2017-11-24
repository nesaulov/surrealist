# frozen_string_literal: true

module Surrealist
  # A helper class for strings transformations.
  module StringUtils
    DASH                  = '-'.freeze
    UNDERSCORE            = '_'.freeze
    EMPTY_STRING          = ''.freeze
    DASH_REGEXP1          = /([A-Z]+)([A-Z][a-z])/o
    DASH_REGEXP2          = /([a-z\d])([A-Z])/o
    UNDERSCORE_REGEXP     = /(?:^|_)([^_\s]+)/o
    NAMESPACES_SEPARATOR  = '::'.freeze
    UNDERSCORE_SUBSTITUTE = '\1_\2'.freeze

    class << self
      # Converts a string to snake_case.
      #
      # @param [String] string a string to be underscored.
      #
      # @return [String] new underscored string.
      def underscore(string)
        string.gsub(NAMESPACES_SEPARATOR, UNDERSCORE)
          .gsub(DASH_REGEXP1, UNDERSCORE_SUBSTITUTE)
          .gsub(DASH_REGEXP2, UNDERSCORE_SUBSTITUTE)
          .tr(DASH, UNDERSCORE)
          .downcase
      end

      # Camelizes a string.
      #
      # @param [String] snake_string a string to be camelized.
      # @param [Boolean] first_upper should the first letter be capitalized.
      #
      # @return [String] camelized string.
      def camelize(snake_string, first_upper = true)
        if first_upper
          snake_string.to_s.gsub(UNDERSCORE_REGEXP) { Regexp.last_match[1].capitalize }
        else
          parts = snake_string.split(UNDERSCORE, 2)
          parts[0] << camelize(parts[1]) if parts.size > 1
          parts[0] || EMPTY_STRING
        end
      end

      # Extracts bottom-level class from a namespace.
      #
      # @param [String] string full namespace
      #
      # @example Extract class
      #   extract_class('Animal::Dog::Collie') # => 'Collie'
      #
      # @return [String] extracted class
      def extract_class(string)
        uncapitalize(string.split(NAMESPACES_SEPARATOR).last)
      end

      # Extracts n amount of classes from a namespaces and returns a nested hash.
      #
      # @param [String] klass full namespace as a string.
      # @param [Boolean] camelize optional camelize argument.
      # @param [Integer] nesting_level level of required nesting.
      #
      # @example 3 levels
      #   klass = 'Business::System::Cashier::Reports::Withdraws'
      #   break_namespaces(klass, camelize: false, nesting_level: 3)
      #   # => { cashier: { reports: { withdraws: {} } } }
      #
      # @raise Surrealist::InvalidNestingLevel if nesting level is specified as 0.
      #
      # @return [Hash] a nested hash.
      def break_namespaces(klass, camelize:, nesting_level:)
        Surrealist::ExceptionRaiser.raise_invalid_nesting!(nesting_level) unless nesting_level > 0

        klass.split(NAMESPACES_SEPARATOR).last(nesting_level).reverse.inject({}) do |a, n|
          camelize ? Hash[camelize(uncapitalize(n), false).to_sym => a] : Hash[underscore(n).to_sym => a]
        end
      end

      private

      # Clones a string and converts first character to lower case.
      #
      # @param [String] string a string to be cloned.
      #
      # @return [String] new string with lower cased first character.
      def uncapitalize(string)
        str = string.dup
        str[0] = str[0].downcase
        str
      end
    end
  end
end
