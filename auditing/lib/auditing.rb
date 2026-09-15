module Auditing
  class Event < RubyEventStore::Event
    def self.from_application(crime_application)
      new(data: event_data(crime_application))
    end

    def self.event_data(crime_application)
      payload = crime_application.submitted_application

      {
        entity_id: crime_application.id,
        business_reference: payload['reference'],
        office_code: payload.dig('provider_details', 'office_code'),
        application_type: crime_application.application_type,
        submitted_at: crime_application.submitted_at
      }.merge(payload.fetch('slipstream_audit_selection_outcome').symbolize_keys)
    end
  end

  # Recorded once, at submission, from the final slipstream audit selection
  # outcome computed by Apply and carried on the submitted application payload.
  class SlipstreamAuditSelectionRecorded < Event; end

  class << self
    def stream_name(business_reference)
      "Auditing$#{business_reference}"
    end
  end

  class Configuration
    class << self
      def call(event_store)
        event_store.subscribe(
          Auditing::Handlers::LinkToStream.new,
          to: [Auditing::SlipstreamAuditSelectionRecorded]
        )
        event_store.subscribe(
          Auditing::Handlers::UpdateReadModel.new,
          to: [Auditing::SlipstreamAuditSelectionRecorded]
        )
      end
    end
  end
end
