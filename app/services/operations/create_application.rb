require 'laa_crime_schemas'

module Operations
  class CreateApplication
    attr_reader :payload

    def initialize(payload:)
      @payload = payload

      validate!
    end

    def call
      app = CrimeApplication.create!(application: payload)

      { id: app.id, status: :created }
    end

    private

    def validate!
      schema_validator = LaaCrimeSchemas::Validator.new(payload)
      return if schema_validator.valid?

      raise LaaCrimeSchemas::Errors::ValidationError, schema_validator.fully_validate
    end
  end
end
