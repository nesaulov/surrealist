module Surrealist
  # A helper class to camelize hash keys and deep copy objects
  class Utils
    class << self
      # Deep copies the schema hash.
      #
      # @param [Object] hash object to be copied
      #
      # @return [Object] a copied object
      def deep_copy(hash)
        Marshal.load(Marshal.dump(hash))
      end

      # Converts hash's keys to camelCase
      #
      # @param [Hash] hash a hash to be camelized
      #
      # @return [Hash] camelized hash
      def camelize_hash(hash)
        if hash.is_a?(Hash)
          Hash[hash.map { |k, v| [camelize_key(k, false), camelize_hash(v)] }]
        else
          hash
        end
      end

      private

      # Converts symbol to string and camelizes it
      #
      # @param [String | Symbol] key a key to be camelized
      #
      # @param [Boolean] first_upper boolean value that stands for some shit
      #
      # @return [String | Symbol] camelized key of a hash
      def camelize_key(key, first_upper = true)
        if key.is_a? Symbol
          camelize(key.to_s, first_upper).to_sym
        elsif key.is_a? String
          camelize(key, first_upper)
        else
          key
        end
      end

      # Camelizes a word
      #
      # @param [String] snake_word a word to be camelized
      #
      # @param [Boolean] first_upper booooo
      #
      # @return [String] camelized string
      def camelize(snake_word, first_upper = true)
        if first_upper
          snake_word.to_s
                    .gsub(/(?:^|_)([^_\s]+)/) { $1.capitalize }
        else
          parts = snake_word.split('_', 2)
          parts[0] << camelize(parts[1]) if parts.size > 1
          parts[0] || ''
        end
      end
    end
  end
end
