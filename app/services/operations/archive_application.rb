module Operations
  class ArchiveApplication
    def initialize(application_id:)
      @application = CrimeApplication.find(application_id)
    end

    def call
      raise Errors::AlreadyArchived if application.archived?
      raise Errors::CannotArchive unless application.returned?

      application.update!(archived_at: Time.zone.now)

      # Publish event notification to the SNS topic
      Events::Archived.new(application).publish
    end

    private

    attr_reader :application
  end
end
