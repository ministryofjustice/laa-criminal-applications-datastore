module Operations
  class ArchiveApplication
    def initialize(application_id:)
      @application = CrimeApplication.find(application_id)
    end

    def call
      raise Errors::AlreadyArchived if application.archived?
      raise Errors::CannotArchive unless application.returned?

      application.update!(archived: true, archived_at: Time.zone.now)
    end

    private

    attr_reader :application
  end
end
