# frozen_string_literal: true

module Surrealist
  class Copier
    class << self
      # Deeply copies the schema hash and wraps it if there is a need to.
      #
      # @param [Object] hash object to be copied.
      # @param [Boolean] include_root optional argument for including root in the hash.
      # @param [Boolean] camelize optional argument for camelizing the root key of the hash.
      # @param [String] klass instance's class name.
      #
      # @return [Object] a copied object
      def deep_copy(hash:, include_root: false, camelize: false, klass: false, include_namespaces:, nesting_level:)
        return copy_hash(hash) unless include_root || include_namespaces || nesting_level != 666
        Surrealist::ExceptionRaiser.raise_unknown_root! if include_root && !klass

        if include_namespaces || nesting_level != 666
          nested_hash = Surrealist::StringUtils.break_namespaces(klass, camelize: camelize, nesting_level: nesting_level)
          inject_schema(nested_hash, copy_hash(hash))
        elsif include_root
          actual_class = Surrealist::StringUtils.extract_class(klass)
          root_key = if camelize
                       Surrealist::StringUtils.camelize(actual_class, false).to_sym
                     else
                       Surrealist::StringUtils.underscore(actual_class).to_sym
                     end
          object = Hash[root_key => {}]
          copy_hash(hash, wrapper: object[root_key])

          object
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

      def inject_schema(hash, sub_hash)
        hash.each do |k, v|
          v == {} ? hash[k] = sub_hash : inject_schema(v, sub_hash)
        end
      end
    end
  end
end
