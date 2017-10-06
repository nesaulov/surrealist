# frozen_string_literal: true

module Surrealist
  # Instance methods that are included to the object's class
  module InstanceMethods
    # Invokes +Surrealist+'s class method +surrealize+
    def surrealize(camelize: false, include_root: false)
      Surrealist.surrealize(instance: self, camelize: camelize, include_root: include_root)
    end

    # Invokes +Surrealist+'s class method +build_schema+
    def build_schema(camelize: false, include_root: false)
      Surrealist.build_schema(instance: self, camelize: camelize, include_root: include_root)
    end
  end
end
