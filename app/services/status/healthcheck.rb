module Status
  class Healthcheck
    attr_reader :status, :error

    def initialize(status:, error:)
      @status = status
      @error = error
    end

    def self.call
      begin
        Dynamoid::Tasks::Database.ping
        status = 200
        error  = nil
      rescue StandardError => e
        status = 503
        error  = e.message
      end

      new(status:, error:)
    end
  end
end
