module Operations
  class SupersedeApplication
    attr_reader :application_id

    def initialize(application_id:)
      @application_id = application_id
    end

    def call
      app = CrimeApplication.returned.find_by(id: application_id)
      app.try(:superseded!)
    end
  end
end
