module Operations
  module MAAT
    class GetApplication
      SCHEMA_NAME = 'maat_application'.freeze
      SCHEMA_VERSION = 1.0

      attr_reader :reference

      def initialize(reference:)
        @reference = reference
      end

      def call
        validate!
        representation
      end

      private

      def validate!
        return if schema_validator.valid?

        raise Errors::NotValidForMAAT, schema_validator.fully_validate.first.fetch(:message)
      end

      def schema_validator
        @schema_validator ||= LaaCrimeSchemas::Validator.new(
          representation.to_json,
          version: SCHEMA_VERSION,
          schema_name: SCHEMA_NAME
        )
      end

      def representation
        raise ActiveRecord::RecordNotFound if record && Rails.env.production?

        Datastore::Entities::V1::MAAT::Application.represent(record)
      end

      def record
        @record ||= CrimeApplication.find_by!(
          reference: reference,
          review_status: [
            Types::ReviewApplicationStatus['ready_for_assessment'],
            Types::ReviewApplicationStatus['assessment_completed']
          ]
        )
      end
    end
  end
end
