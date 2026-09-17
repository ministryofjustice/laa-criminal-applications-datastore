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
        {
          crime_application_id: data.fetch(:entity_id),
          business_reference: data.fetch(:business_reference),
          office_code: data.fetch(:office_code),
          application_type: data.fetch(:application_type),
          offences: data.fetch(:offences),
          status: data.fetch(:status),
          sample_rate: data.fetch(:sample_rate),
          sampled_at: data.fetch(:sampled_at),
          status_determined_at: data.fetch(:status_determined_at),
          submitted_at: data.fetch(:submitted_at)
        }
      end
    end
  end
end
