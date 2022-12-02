require 'laa_crime_schemas'

module Operations
  module Dynamodb
    class CreateApplication
      attr_reader :payload

      def initialize(payload:)
        @payload = payload

        validate!
      end

      def call
        app = ::Dynamodb::CrimeApplication.create(payload)

        { id: app.id, status: app.status }
      end

      private

      def validate!
        schema_validator = LaaCrimeSchemas::Validator.new(payload)
        return if schema_validator.valid?

        raise LaaCrimeSchemas::Errors::ValidationError, schema_validator.fully_validate
      end
    end
  end
end
