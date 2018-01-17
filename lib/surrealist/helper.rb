# frozen_string_literal: true

module Surrealist
  # A generic helper.
  module Helper
    # Determines if the class uses the Surrealist mixin.
    #
    # @param [Class] klass a class to be checked.
    #
    # @return [Boolean] if Surrealist is included in class.
    def self.surrealist?(klass)
      klass < Surrealist || klass < Surrealist::Serializer
    end
  end
end
