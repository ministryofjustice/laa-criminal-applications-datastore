module Operations
  module Dynamodb
    class UpdateApplication
      attr_reader :application_id,
                  :payload

      def initialize(application_id, payload:)
        @application_id = application_id
        @payload = payload
      end

      def call
        ::Dynamodb::CrimeApplication.update(application_id, payload)

        { id: application_id }.merge(payload)
      end
    end
  end
end
