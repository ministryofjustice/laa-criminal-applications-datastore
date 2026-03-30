module Operations
  class ArchiveApplication
    def initialize(application_id:)
      @application = CrimeApplication.find(application_id)
    end

    # rubocop:disable Metrics/AbcSize
    def call
      raise Errors::AlreadyArchived if application.archived?
      raise Errors::CannotArchive unless application.returned?

      application.transaction do
        application.update!(archived_at: Time.zone.now)

        event = Deleting::Archived.new(data: { business_reference: application.reference,
                                               entity_id: application.id,
                                               entity_type: application.application_type,
                                               archived_at: application.archived_at })

        Rails.configuration.event_store.publish(event)
      end
    end
    # rubocop:enable Metrics/AbcSize

    private

    attr_reader :application
  end
end
