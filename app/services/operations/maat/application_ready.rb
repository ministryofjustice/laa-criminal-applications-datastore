require 'laa_crime_schemas'

module Operations
  module Maat
    class ApplicationReady
      attr_reader :usn

      def initialize(usn:)
        @usn = usn
      end

      def call
        application = CrimeApplication.find_by(reference: usn, review_status: :ready_for_assessment)

        raise ActiveRecord::RecordNotFound unless application

        application
      end
    end
  end
end
