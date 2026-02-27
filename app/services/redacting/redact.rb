module Redacting
  class Redact < BaseRedacting
    def initialize(record)
      raise ArgumentError, "expected `CrimeApplication` instance, got `#{record.class}`" unless
        record.is_a?(CrimeApplication)

      super
    end

    def process!(force: false)
      process_metadata!

      # The redacting of the payload is only needed once, on creation
      # The `force` param can be used to perform the redaction adhoc if required
      return true if redacted_record.persisted? && !force

      # First we create an exact copy of the original payload
      redacted_payload.merge!(
        original_payload.dup
      )

      # Then we redact from this copy anything according to the rules
      Rules.pii_attributes.each do |path, rules|
        redact_attribute(path.split('.'), rules)
      end

      true
    end

    def process_metadata!
      redacted_record.metadata.merge!(
        MetadataWrapper.new(record).metadata
      )

      true
    end

    private

    def redact_attribute(path, rules)
      payload_details = redacted_payload.dig(*path)
      return if payload_details.blank?

      fields = rules.fetch(:redact)
      type   = rules.fetch(:type, :object)

      details = details_by_type(payload_details, type, fields)
      merge_redacted(path, details)
    end

    def details_by_type(details, type, fields)
      case type
      when :object
        details.slice(*fields).compact_blank
      when :array
        details.map { |item| item.slice(*fields).compact_blank }
      when :string
        details
      else
        raise "unknown rule path type: #{type}"
      end
    end

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
      elsif details.is_a?(String)
        REDACTED_KEYWORD
      else
        details.each_key { |key| details[key] = REDACTED_KEYWORD }
      end
    end
  end
end
