# frozen_string_literal: true

module Surrealist
  # A helper class for deep copying and wrapping hashes.
  class Copier
    class << self
      # Deeply copies the schema hash and wraps it if there is a need to.
      #
      # @param [Object] hash object to be copied.
      # @param [String] klass instance's class name.
      # @param [Object] carrier instance of Carrier class that carries arguments passed to +surrealize+
      #
      # @return [Hash] a copied hash.
      def deep_copy(hash:, klass: false, carrier:)
        namespaces_condition = carrier.include_namespaces || carrier.namespaces_nesting_level != DEFAULT_NESTING_LEVEL # rubocop:disable Metrics/LineLength

        if !klass && (carrier.include_root || namespaces_condition)
          Surrealist::ExceptionRaiser.raise_unknown_root!
        end

        copy_before_root = copied_and_possibly_wrapped_hash(hash, klass, carrier, namespaces_condition)

        if carrier.root
          wrap_schema_into_root(schema: copy_before_root, carrier: carrier, root: carrier.root)
        else
          copy_before_root
        end
      end

      private

      # Deeply copies the schema hash and wraps it if there is a need to.
      #
      # @param [Object] hash object to be copied.
      # @param [String] klass instance's class name.
      # @param [Object] carrier instance of Carrier class that carries arguments passed to +surrealize+
      # @param [Bool] namespaces_condition whether to wrap into namespace.
      #
      # @return [Hash] deeply copied hash, possibly wrapped.
      def copied_and_possibly_wrapped_hash(hash, klass, carrier, namespaces_condition)
        if namespaces_condition
          wrap_schema_into_namespace(schema: hash, klass: klass, carrier: carrier)
        elsif carrier.include_root
          actual_class = Surrealist::StringUtils.extract_class(klass)
          wrap_schema_into_root(schema: hash, carrier: carrier, root: actual_class)
        else
          copy_hash(hash)
        end
      end

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

      # Wraps schema into a root key if `include_root` is passed to Surrealist.
      #
      # @param [Hash] schema schema hash.
      # @param [Object] carrier instance of Carrier class that carries arguments passed to +surrealize+
      # @param [String] root what the schema will be wrapped into
      #
      # @return [Hash] a hash with schema wrapped inside a root key.
      def wrap_schema_into_root(schema:, carrier:, root:)
        root_key = if carrier.camelize
                     Surrealist::StringUtils.camelize(root, false).to_sym
                   else
                     Surrealist::StringUtils.underscore(root).to_sym
                   end
        result = Hash[root_key => {}]
        copy_hash(schema, wrapper: result[root_key])

        result
      end

      # Wraps schema into a nested hash of namespaces.
      #
      # @param [Hash] schema main schema.
      # @param [String] klass name of the class where schema is defined.
      # @param [Object] carrier instance of Carrier class that carries arguments passed to +surrealize+
      #
      # @return [Hash] nested hash (see +inject_schema+)
      def wrap_schema_into_namespace(schema:, klass:, carrier:)
        nested_hash = Surrealist::StringUtils.break_namespaces(
          klass,
          camelize: carrier.camelize,
          nesting_level: carrier.namespaces_nesting_level,
        )

        inject_schema(nested_hash, copy_hash(schema))
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
    end
  end
end
