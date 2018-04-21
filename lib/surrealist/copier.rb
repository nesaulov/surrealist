# frozen_string_literal: true

module Surrealist
  # A helper class for deep copying and wrapping hashes.
  module Copier
    class << self
      # Goes through the hash recursively and deeply copies it.
      #
      # @param [Hash] hash the hash to be copied.
      # @param [Hash] wrapper the wrapper of the resulting hash.
      #
      # @return [Hash] deeply copied hash.
      def deep_copy(hash, wrapper = {})
        hash.each_with_object(wrapper) do |(key, value), new|
          new[key] = value.is_a?(Hash) ? deep_copy(value) : value
        end
      end
    end
  end
end
