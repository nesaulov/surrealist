# frozen_string_literal: true

module Surrealist
  # Instance methods that are included to the object's class
  module InstanceMethods
    # Invokes +Surrealist+'s class method +surrealize+
    def surrealize(camelize: false)
      Surrealist.surrealize(self, camelize: camelize)
    end

    # Invokes +Surrealist+'s class method +build_schema+
    def build_schema(camelize: false)
      Surrealist.build_schema(self, camelize: camelize)
    end
  end
end
