# frozen_string_literal: true

module Surrealist
  class Configuration
    # A class that is responsible for validating Configuration objects.
    class Validator
      BOOLEAN_SETTINGS = %i[camelize include_root include_namespaces].freeze

      def initialize(configuration)
        @config = configuration
      end

      def call
        validate_boolean_settings!
        validate_namespace_nesting!
        validate_root!
      end

      private

      attr_reader :config

      def validate_boolean_settings!
        BOOLEAN_SETTINGS.each do |setting|
          value = config.public_send(setting)

          next if value.nil?
          next if value == false
          next if value == true

          raise ArgumentError, "Expected `#{setting}` to be either true, false or nil, got #{value}"
        end
      end

      def validate_namespace_nesting!
        namespace_nesting_level = config.namespace_nesting_level
        return if namespace_nesting_level.is_a?(Integer) && namespace_nesting_level.positive?

        Surrealist::ExceptionRaiser.raise_invalid_nesting!(namespace_nesting_level)
      end

      def validate_root!
        root = config.root

        return if root.nil?
        return if root.is_a?(Symbol)
        return if root.is_a?(String) && !root.empty?

        Surrealist::ExceptionRaiser.raise_invalid_root!(root)
      end
    end
  end
end
