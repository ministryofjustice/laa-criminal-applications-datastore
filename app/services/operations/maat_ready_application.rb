require 'laa_crime_schemas'

module Operations
  class MaatReadyApplication
    attr_reader :usn

    def initialize(usn:)
      @usn = usn
    end

    def call
      application = CrimeApplication.find_by(reference: usn)

      raise Errors::NotMarkedAsReady unless application.ready_for_assessment?

      application
    end
  end
end
