module Surrealist
  # Module for finding and setting hash into vars
  module VarsFinder
    # Instance variable name that is set by SchemaDefiner
    INSTANCE_VARIABLE = '@__surrealist_schema'.freeze
    # Instance's parent instance variable name that is set by SchemaDefiner
    PARENT_VARIABLE = '@__surrealist_schema_parent'.freeze
    # Class variable name that is set by SchemaDefiner
    CLASS_VARIABLE = '@@__surrealist_schema'.freeze
    # Regexp to resolve ROM structure
    ROM_REGEXP = /ROM::Struct/o

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

      private

      def use_class_var?(klass)
        klass.name =~ ROM_REGEXP
      end
    end
  end
end
