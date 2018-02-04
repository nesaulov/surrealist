module Surrealist
  # Module for finding and setting hash into vars
  module VarsHelper
    # Instance variable name that is set by SchemaDefiner
    INSTANCE_VARIABLE = '@__surrealist_schema'.freeze
    # Instance's parent instance variable name that is set by SchemaDefiner
    PARENT_VARIABLE = '@__surrealist_schema_parent'.freeze
    # Class variable name that is set by SchemaDefiner
    CLASS_VARIABLE = '@@__surrealist_schema'.freeze
    # Regexp to resolve ROM structure
    ROM_REGEXP = /ROM::Struct/o
    # Instance variable that keeps serializer classes
    SERIALIZER_CLASSES = '@__surrealist_serializers'.freeze
    # Tag for default behaviour in multiple serializers
    DEFAULT_TAG = :default

    class << self
      # Find the schema
      #
      # @param [Class] klass Class that included Surrealist
      #
      # @return [Hash] Found hash
      def find_schema(klass)
        if use_class_var?(klass)
          klass.class_variable_get(CLASS_VARIABLE) if klass.class_variable_defined?(CLASS_VARIABLE)
        else
          klass.instance_variable_get(INSTANCE_VARIABLE)
        end
      end

      # Setting schema into var
      #
      # @param [Class] klass Class that included Surrealist
      # @param [Hash] hash Schema hash
      def set_schema(klass, hash)
        if use_class_var?(klass)
          klass.class_variable_set(CLASS_VARIABLE, hash)
        else
          klass.instance_variable_set(INSTANCE_VARIABLE, hash)
        end
      end

      # Checks if there is a serializer defined for a given class and returns it
      #
      # @param [Class] klass a class to check
      # @param [Symbol] tag a tag associated with serializer
      #
      # @return [Class | nil]
      def find_serializer(klass, tag: nil)
        tag ||= DEFAULT_TAG
        hash = klass.instance_variable_get(SERIALIZER_CLASSES)
        serializer = hash && hash.fetch(tag.to_sym, nil)
        Surrealist::ExceptionRaiser.raise_unknown_tag!(tag) if serializer.nil? && tag != DEFAULT_TAG
        serializer
      end

      # Sets a serializer for class
      #
      # @param [Class] self_class class of object that points to serializer
      # @param [Class] serializer_class class of serializer
      # @param [Symbol] tag a tag associated with serializer
      def add_serializer(self_class, serializer_class, tag: nil)
        tag ||= DEFAULT_TAG
        hash = self_class.instance_variable_get(SERIALIZER_CLASSES) || {}
        hash[tag.to_sym] = serializer_class
        self_class.instance_variable_set(SERIALIZER_CLASSES, hash)
      end

      private

      def use_class_var?(klass)
        klass.name =~ ROM_REGEXP
      end
    end
  end
end
