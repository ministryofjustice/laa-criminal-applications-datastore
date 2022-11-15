module Operations
  class DeleteApplication
    attr_reader :application_id

    def initialize(application_id)
      @application_id = application_id
    end

    def call
      CrimeApplication.find(application_id).destroy
    end
  end
end
