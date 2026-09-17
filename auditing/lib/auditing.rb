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
        offences: offences(payload),
        submitted_at: crime_application.submitted_at
      }.merge(payload.fetch('slipstream_audit_selection_outcome').symbolize_keys)
    end

    def self.offences(payload)
      Array(payload.dig('case_details', 'offences')).map do |offence|
        offence.slice('name', 'offence_class', 'slipstreamable')
      end
    end
  end

  # Recorded once, at submission, from the final slipstream audit selection
  # outcome computed by Apply and carried on the submitted application payload.
  class SlipstreamAuditSelectionRecorded < Event; end

  # Recorded when Review completes the assessment, carrying the post-submission
  # attributes (MAAT reference and interests of justice outcome) that only exist
  # once a decision has been made.
  class AssessmentOutcomeRecorded < Event
    def self.from_application(crime_application:, decision:)
      new(
        data: {
          entity_id: crime_application.id,
          business_reference: crime_application.reference,
          maat_reference: decision&.maat_id,
          ioj_outcome: decision&.interests_of_justice&.dig('result')
        }
      )
    end
  end

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
          to: [Auditing::SlipstreamAuditSelectionRecorded, Auditing::AssessmentOutcomeRecorded]
        )
        event_store.subscribe(
          Auditing::Handlers::UpdateReadModel.new,
          to: [Auditing::SlipstreamAuditSelectionRecorded]
        )
        event_store.subscribe(
          Auditing::Handlers::ProjectAssessmentOutcome.new,
          to: [Auditing::AssessmentOutcomeRecorded]
        )
      end
    end
  end
end
