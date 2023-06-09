module Redacting
  class Redact < BaseRedacting
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def process!
      Rules.all.each do |path, rules|
        path = path.split('.')
        details = exposed_payload&.dig(*path)

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

        protect_and_redact(path, details)
      end

      true
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    private

    def protect_and_redact(path, details)
      protected_payload.deep_merge!(
        traverse(path, details)
      )

      exposed_payload.deep_merge!(
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
