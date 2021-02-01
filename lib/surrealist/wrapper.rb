# frozen_string_literal: true

module Surrealist
  # A helper class for wrapping hashes.
  module Wrapper
    class << self
      # Wraps the schema hash into root/namespaces if there is a need to.
      #
      # @param [Object] hash to be wrapped.
      # @param [Object] carrier instance of Carrier class that carries arguments passed to +surrealize+
      # @param [String] klass instance's class name.
      #
      # @return [Hash] a wrapped hash.
      def wrap(hash, carrier, klass: false)
        namespaces_condition = carrier.include_namespaces || carrier.namespaces_nesting_level != DEFAULT_NESTING_LEVEL # rubocop:disable Layout/LineLength

        if !klass && (carrier.include_root || namespaces_condition)
          Surrealist::ExceptionRaiser.raise_unknown_root!
        end

        possibly_wrapped_hash(hash, klass, carrier, namespaces_condition)
      end

      private

      # Deeply copies the schema hash and wraps it if there is a need to.
      # TODO: refactor
      #
      # @param [Object] hash object to be copied.
      # @param [String] klass instance's class name.
      # @param [Object] carrier instance of Carrier class that carries arguments passed to +surrealize+
      # @param [Bool] namespaces_condition whether to wrap into namespace.
      #
      # @return [Hash] deeply copied hash, possibly wrapped.
      def possibly_wrapped_hash(hash, klass, carrier, namespaces_condition)
        return hash if carrier.no_args_provided?

        if carrier.root
          wrap_schema_into_root(hash, carrier, carrier.root.to_s)
        elsif namespaces_condition
          wrap_schema_into_namespace(hash, carrier, klass)
        elsif carrier.include_root
          actual_class = Surrealist::StringUtils.extract_class(klass)
          wrap_schema_into_root(hash, carrier, actual_class)
        else
          hash
        end
      end

      # Wraps schema into a root key if `include_root` is passed to Surrealist.
      #
      # @param [Hash] schema schema hash.
      # @param [Object] carrier instance of Carrier class that carries arguments passed to +surrealize+
      # @param [String] root what the schema will be wrapped into
      #
      # @return [Hash] a hash with schema wrapped inside a root key.
      def wrap_schema_into_root(schema, carrier, root)
        root_key = if carrier.camelize
                     Surrealist::StringUtils.camelize(root, first_upper: false).to_sym
                   else
                     Surrealist::StringUtils.underscore(root).to_sym
                   end
        result = { root_key => {} }
        Surrealist::Copier.deep_copy(schema, result[root_key])

        result
      end

      # Wraps schema into a nested hash of namespaces.
      #
      # @param [Hash] schema main schema.
      # @param [String] klass name of the class where schema is defined.
      # @param [Object] carrier instance of Carrier class that carries arguments passed to +surrealize+
      #
      # @return [Hash] nested hash (see +inject_schema+)
      def wrap_schema_into_namespace(schema, carrier, klass)
        nested_hash = Surrealist::StringUtils.break_namespaces(
          klass, carrier.camelize, carrier.namespaces_nesting_level
        )

        inject_schema(nested_hash, Surrealist::Copier.deep_copy(schema))
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
          v == Surrealist::HashUtils::EMPTY_HASH ? hash[k] = sub_hash : inject_schema(v, sub_hash)
        end
      end
    end
  end
end
