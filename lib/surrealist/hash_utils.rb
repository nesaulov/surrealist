# frozen_string_literal: true

module Surrealist
  # A helper class for hashes transformations.
  module HashUtils
    EMPTY_HASH = {}.freeze

    class << self
      # Converts hash's keys to camelBack keys.
      #
      # @param [Hash] hash a hash to be camelized.
      #
      # @return [Hash] camelized hash.
      def camelize_hash(hash)
        return hash unless hash.is_a?(Hash)

        hash.each_with_object({}) do |(k, v), obj|
          obj[camelize_key(k, false)] = camelize_hash(v)
        end
      end

      private

      # Converts symbol to string and camelizes it.
      #
      # @param [String | Symbol] key a key to be camelized.
      # @param [Boolean] first_upper should the first letter be capitalized.
      #
      # @return [String | Symbol] camelized key of a hash.
      def camelize_key(key, first_upper = true)
        if key.is_a? Symbol
          Surrealist::StringUtils.camelize(key.to_s, first_upper).to_sym
        elsif key.is_a? String
          Surrealist::StringUtils.camelize(key, first_upper)
        else
          key
        end
      end
    end
  end
end
