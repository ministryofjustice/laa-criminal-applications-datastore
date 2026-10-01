module Auditing
  module Handlers
    # Projects the audit event stream into the final-state read model,
    # keeping a single row per application reference. A returned and
    # resubmitted application updates the same row rather than duplicating it.
    class UpdateReadModel
      def call(event)
        SlipstreamAuditSelectionOutcome.upsert( # rubocop:disable Rails/SkipsModelValidations
          read_model_attributes(event.data),
          unique_by: :business_reference
        )
      end

      private

      def read_model_attributes(data)
        data.slice(
          :business_reference, :office_code, :application_type, :offences, :status,
          :selection_reason, :sample_rate, :sampled_at, :status_determined_at, :submitted_at
        ).merge(crime_application_id: data.fetch(:entity_id))
      end
    end
  end
end
