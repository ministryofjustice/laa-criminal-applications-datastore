module Operations
  class CreateApplication
    attr_reader :payload

    def initialize(payload:)
      @payload = payload
    end

    def call
      app = CrimeApplication.create(payload)

      { id: app.id, status: app.status }
    end
  end
end
