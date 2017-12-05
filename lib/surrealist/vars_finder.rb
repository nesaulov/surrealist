# frozen_string_literal: true

module Surrealist
  # A helper module that finds aliases and schemes in classes
  module VarsFinder
    # Instance variable name that is set by SchemaDefiner
    SCHEMA_INSTANCE_VARIABLE = '@__surrealist_schema'.freeze
    # Instance's parent instance variable name that is set by SchemaDefiner
    SCHEMA_PARENT_VARIABLE = '@__surrealist_schema_parent'.freeze
    # Class variable name that is set by SchemaDefiner
    SCHEMA_CLASS_VARIABLE = '@@__surrealist_schema'.freeze
    # Class variable name that stores aliases hash
    ALIASES_INSTANCE_VARIABLE = '@__surrealist_aliases'.freeze

    class << self
      def find_schema(instance)
        delegatee = instance.class.instance_variable_get(SCHEMA_PARENT_VARIABLE)
        maybe_schema = (delegatee || instance.class).instance_variable_get(SCHEMA_INSTANCE_VARIABLE)
        maybe_schema ||
          (instance.class.class_variable_get(SCHEMA_CLASS_VARIABLE) if klass_var_defined?(instance))
      end

      def find_aliases(instance)
        instance.class.instance_variable_get(ALIASES_INSTANCE_VARIABLE) || {}
      end

      private

      def klass_var_defined?(instance)
        instance.class.class_variable_defined?(SCHEMA_CLASS_VARIABLE)
      end
    end
  end
end
