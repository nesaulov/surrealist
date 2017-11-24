# frozen_string_literal: true

module Surrealist
  # A data structure to carry arguments across methods.
  class Carrier
    BOOLEANS = [true, false].freeze

    attr_reader :camelize, :include_root, :include_namespaces, :root, :namespaces_nesting_level

    # Public wrapper for Carrier.
    #
    # @param [Boolean] camelize optional argument for converting hash to camelBack.
    # @param [Boolean] include_root optional argument for having the root key of the resulting hash
    #   as instance's class name.
    # @param [Boolean] include_namespaces optional argument for having root key as a nested hash of
    #   instance's namespaces. Animal::Cat.new.surrealize -> (animal: { cat: { weight: '3 kilos' } })
    # @param [String] root optional argument for using a specified root key for the resulting hash
    # @param [Integer] namespaces_nesting_level level of namespaces nesting.
    #
    # @raise ArgumentError if types of arguments are wrong.
    #
    # @return [Carrier] self if type checks were passed.
    def self.call(camelize:, include_root:, include_namespaces:, root:, namespaces_nesting_level:)
      new(camelize, include_root, include_namespaces, root, namespaces_nesting_level).sanitize!
    end

    def initialize(camelize, include_root, include_namespaces, root, namespaces_nesting_level)
      @camelize                 = camelize
      @include_root             = include_root
      @include_namespaces       = include_namespaces
      @root                     = root
      @namespaces_nesting_level = namespaces_nesting_level
    end

    # Performs type checks
    #
    # @return [Carrier] self if check were passed
    def sanitize!
      check_booleans!
      check_namespaces_nesting!
      check_root!
      strip_root!
      self
    end

    private

    # Checks all boolean arguments
    # @raise ArgumentError
    def check_booleans!
      booleans_hash.each do |key, value|
        unless BOOLEANS.include?(value)
          raise ArgumentError, "Expected `#{key}` to be either true or false, got #{value}"
        end
      end
    end

    # Helper hash for all boolean arguments
    def booleans_hash
      { camelize: camelize, include_root: include_root, include_namespaces: include_namespaces }
    end

    # Checks if +namespaces_nesting_level+ is a positive integer
    # @raise ArgumentError
    def check_namespaces_nesting!
      unless namespaces_nesting_level.is_a?(Integer)
        Surrealist::ExceptionRaiser.raise_invalid_nesting!(namespaces_nesting_level)
      end

      if namespaces_nesting_level <= 0
        Surrealist::ExceptionRaiser.raise_invalid_nesting!(namespaces_nesting_level)
      end
    end

    # Checks if root is not nil, a non-empty string, or symbol
    # @raise ArgumentError
    def check_root!
      unless root.nil? || (root.is_a?(String) && !root.strip.empty?) || root.is_a?(Symbol)
        Surrealist::ExceptionRaiser.raise_invalid_root!(root)
      end
    end

    # Strips root of empty whitespaces
    def strip_root!
      root.is_a?(String) && @root = root.strip
    end
  end
end
