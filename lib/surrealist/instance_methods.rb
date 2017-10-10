# frozen_string_literal: true

module Surrealist
  # Instance methods that are included to the object's class
  module InstanceMethods
    # Invokes +Surrealist+'s class method +surrealize+
    def surrealize(camelize: false, include_root: false, include_namespaces: false, namespaces_nesting_level: 666) # rubocop:disable Metrics/LineLength
      Surrealist.surrealize(
        instance: self,
        camelize: camelize,
        include_root: include_root,
        include_namespaces: include_namespaces,
        namespaces_nesting_level: namespaces_nesting_level,
      )
    end

    # Invokes +Surrealist+'s class method +build_schema+
    def build_schema(camelize: false, include_root: false, include_namespaces: false, namespaces_nesting_level: 666) # rubocop:disable Metrics/LineLength
      Surrealist.build_schema(
        instance: self,
        camelize: camelize,
        include_root: include_root,
        include_namespaces: include_namespaces,
        namespaces_nesting_level: namespaces_nesting_level,
      )
    end
  end
end
