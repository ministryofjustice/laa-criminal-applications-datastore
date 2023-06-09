module Redacting
  class Unredact < BaseRedacting
    def initialize(record)
      raise ArgumentError, "expected `RedactedCrimeApplication` instance, got `#{record.class}`" unless
        record.is_a?(RedactedCrimeApplication)

      super(record.crime_application)
    end

    def process!
      Rules.all.each_key do |path|
        path = path.split('.')
        details = original_payload.dig(*path)

        unredact(path, details) if details.present?
      end

      true
    end

    private

    def unredact(path, details)
      redacted_payload.deep_merge!(
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
