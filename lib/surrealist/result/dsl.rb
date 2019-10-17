# frozen_string_literal: true

module Surrealist
  module Result
    # Convenience methods for working with type systems.
    module DSL
      def success
        Result::Success::INSTANCE
      end

      def failure(error_message)
        Result::Failure.new(error_message)
      end
    end
  end
end
