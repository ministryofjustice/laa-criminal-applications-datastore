module Redacting
  class Unredact < BaseRedacting
    def process!
      Rules.all.each_key do |path|
        path = path.split('.')
        details = protected_payload&.dig(*path)

        unredact(path, details) if details.present?
      end

      true
    end

    private

    def unredact(path, details)
      exposed_payload.deep_merge!(
        traverse(path, details)
      ) do |_key, redacted, original|
        if redacted.is_a?(Array)
          # Handle collection of hashes, for example `codefendants`
          redacted.map.with_index { |item, index| item.deep_merge(original[index]) }
        else
          original
        end
      end
    end
  end
end
