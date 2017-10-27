module Surrealist
  # A generic helper.
  class Helper
    class << self
      # Determines if the class uses the Surrealist mixin.
      #
      # @param [Class] to be checked.
      #
      # @return [Boolean] if Surrealist is included in class.
      def surrealist?(klass)
        klass < Surrealist
      end
    end
  end
end
