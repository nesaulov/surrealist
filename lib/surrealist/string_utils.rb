module Surrealist
  class StringUtils
    class << self
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

      # Converts a string to snake_case.
      #
      # @param [String] string a string to be underscored.
      #
      # @return [String] underscored string.
      def underscore(string)
        string.gsub('::', '_')
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr('-', '_')
          .downcase
      end

      # Extract last class from a namespace.
      #
      # @param [String] string full namespace
      #
      # @example Extract class
      #   extract_class('Animal::Dog::Collie') # => 'Collie'
      #
      # @return [String] extracted class
      def extract_class(string)
        uncapitalize(string.split('::').last)
      end

      def break_namespaces(string, camelize:, nesting_level:)
        Surrealist::ExceptionRaiser.raise_invalid_nesting_level! if nesting_level.zero?
        arr = string.split('::')
        arr.last(nesting_level).reverse.inject({}) do |a, n|
          camelize ? Hash[camelize(uncapitalize(n), false).to_sym => a] : Hash[underscore(n).to_sym => a]
        end
      end

      # Camelizes a string.
      #
      # @param [String] snake_string a string to be camelized.
      # @param [Boolean] first_upper should the first letter be capitalized.
      #
      # @return [String] camelized string.
      def camelize(snake_string, first_upper = true)
        if first_upper
          snake_string.to_s
            .gsub(/(?:^|_)([^_\s]+)/) { Regexp.last_match[1].capitalize }
        else
          parts = snake_string.split('_', 2)
          parts[0] << camelize(parts[1]) if parts.size > 1
          parts[0] || ''
        end
      end
    end
  end
end
