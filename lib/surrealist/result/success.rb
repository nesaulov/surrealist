# frozen_string_literal: true

module Surrealist
  module Result
    # A successful result.
    class Success
      def success?
        if block_given?
          yield
        else
          true
        end
      end

      def failure?
        false
      end

      INSTANCE = new.freeze
    end
  end
end
