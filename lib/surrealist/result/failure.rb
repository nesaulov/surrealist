# frozen_string_literal: true

module Surrealist
  module Result
    # A failed result.
    class Failure
      def initialize(error_message)
        @error_message = error_message
      end

      def success?
        false
      end

      def failure?
        if block_given?
          yield @error_message
        else
          true
        end
      end
    end
  end
end
