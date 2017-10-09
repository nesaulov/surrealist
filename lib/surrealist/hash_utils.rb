# frozen_string_literal: true

module Surrealist
  # A helper class to camelize, wrap and deeply copy hashes.
  class HashUtils
    class << self
      # Deeply copies the schema hash and wraps it if there is a need to.
      #
      # @param [Object] hash object to be copied.
      # @param [Boolean] include_root optional argument for including root in the hash.
      # @param [Boolean] camelize optional argument for camelizing the root key of the hash.
      # @param [String] klass instance's class name.
      #
      # @return [Object] a copied object
      def deep_copy(hash:, include_root: false, camelize: false, klass: false)
        return copy_hash(hash) unless include_root
        Surrealist::ExceptionRaiser.raise_unknown_root! if include_root && !klass

        actual_class = extract_class(klass)
        root_key = camelize ? camelize(actual_class, false).to_sym : underscore(actual_class).to_sym
        object = Hash[root_key => {}]
        copy_hash(hash, wrapper: object[root_key])

        object
      end

      # Converts hash's keys to camelBack keys.
      #
      # @param [Hash] hash a hash to be camelized.
      #
      # @return [Hash] camelized hash.
      def camelize_hash(hash)
        if hash.is_a?(Hash)
          Hash[hash.map { |k, v| [camelize_key(k, false), camelize_hash(v)] }]
        else
          hash
        end
      end

      private

      # Goes through the hash recursively and deeply copies it.
      #
      # @param [Hash] hash the hash to be copied.
      # @param [Hash] wrapper the wrapper of the resulting hash.
      #
      # @return [Hash] deeply copied hash.
      def copy_hash(hash, wrapper: {})
        hash.each_with_object(wrapper) do |(key, value), new|
          new[key] = value.is_a?(Hash) ? copy_hash(value) : value
        end
      end

      # Converts symbol to string and camelizes it.
      #
      # @param [String | Symbol] key a key to be camelized.
      # @param [Boolean] first_upper should the first letter be capitalized.
      #
      # @return [String | Symbol] camelized key of a hash.
      def camelize_key(key, first_upper = true)
        if key.is_a? Symbol
          camelize(key.to_s, first_upper).to_sym
        elsif key.is_a? String
          camelize(key, first_upper)
        else
          key
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
    end
  end
end
