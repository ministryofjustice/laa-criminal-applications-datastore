module Redacting
  class Redact < BaseRedacting
    def initialize(record)
      raise ArgumentError, "expected `CrimeApplication` instance, got `#{record.class}`" unless
        record.is_a?(CrimeApplication)

      super(record)
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def process!
      process_metadata!

      # The redacting of the payload is only needed once, on creation
      return true if redacted_record.persisted?

      # First we create an exact copy of the original payload
      redacted_payload.merge!(
        original_payload.dup
      )

      # Then we redact from this copy anything according to the rules
      Rules.all.each do |path, rules|
        path = path.split('.')
        details = redacted_payload.dig(*path)

        next if details.blank?

        fields = rules.fetch(:redact)
        type   = rules.fetch(:type, :object)

        details = case type
                  when :object
                    details.slice(*fields).compact_blank
                  when :array
                    details.map { |item| item.slice(*fields).compact_blank }
                  else
                    raise "unknown rule path type: #{type}"
                  end

        merge_redacted(path, details)
      end

      true
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def process_metadata!
      redacted_record.metadata.merge!(
        record.slice(
          :status,
          :returned_at,
          :reviewed_at,
          :review_status,
          :offence_class,
        )
      )

      true
    end

    private

    def merge_redacted(path, details)
      redacted_payload.deep_merge!(
        traverse(path, redact(details.dup))
      ) do |_key, original, redacted|
        if original.is_a?(Array)
          # Handle collection of hashes, for example `codefendants`
          original.map.with_index { |item, index| item.deep_merge(redacted[index]) }
        else
          redacted
        end
      end
    end

    def redact(details)
      if details.is_a?(Array)
        details.map { |item| redact(item.dup) }
      else
        details.each_key { |key| details[key] = REDACTED_KEYWORD }
      end
    end
  end
end