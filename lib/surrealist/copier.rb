# frozen_string_literal: true

module Surrealist
  # A helper class for deep copying and wrapping hashes.
  class Copier
    class << self
      # Deeply copies the schema hash and wraps it if there is a need to.
      #
      # @param [Object] hash object to be copied.
      # @param [Boolean] include_root optional argument for including root in the hash.
      # @param [Boolean] camelize optional argument for camelizing the root key of the hash.
      # @param [String] klass instance's class name.
      #
      # @return [Object] a copied object.
      def deep_copy(hash:, include_root: false, camelize: false, klass: false, include_namespaces: false, nesting_level: DEFAULT_NESTING_LEVEL) # rubocop:disable Metrics/LineLength
        unless include_root || include_namespaces || nesting_level != DEFAULT_NESTING_LEVEL
          return copy_hash(hash)
        end

        Surrealist::ExceptionRaiser.raise_unknown_root! unless klass

        if include_namespaces || nesting_level != DEFAULT_NESTING_LEVEL
          nested_hash = Surrealist::StringUtils.break_namespaces(klass,
                                                                 camelize: camelize,
                                                                 nesting_level: nesting_level)
          inject_schema(nested_hash, copy_hash(hash))
        elsif include_root
          wrap_schema_into_root(hash: hash, klass: klass, camelize: camelize)
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

      # Injects one hash into another nested hash.
      #
      # @param [Hash] hash wrapper-hash.
      # @param [Hash] sub_hash hash to be injected.
      #
      # @example wrapping hash
      #  hash = { one: { two: { three: {} } } }
      #  sub_hash = { four: '4' }
      #
      #  inject_schema(hash, sub_hash)
      #  # => { one: { two: { three: { four: '4' } } } }
      #
      # @return [Hash] resulting hash.
      def inject_schema(hash, sub_hash)
        hash.each do |k, v|
          v == {} ? hash[k] = sub_hash : inject_schema(v, sub_hash)
        end
      end

      # Wraps schema into a root key if `include_root` is passed to Surrealist.
      #
      # @param [Hash] hash schema hash.
      # @param [String] klass name of the class where schema is defined.
      # @param [Boolean] camelize optional camelize argument.
      #
      # @return [Hash] a hash with schema wrapped inside a root key.
      def wrap_schema_into_root(hash:, klass:, camelize:)
        actual_class = Surrealist::StringUtils.extract_class(klass)
        root_key = if camelize
                     Surrealist::StringUtils.camelize(actual_class, false).to_sym
                   else
                     Surrealist::StringUtils.underscore(actual_class).to_sym
                   end
        result = Hash[root_key => {}]
        copy_hash(hash, wrapper: result[root_key])

        result
      end
    end
  end
end
