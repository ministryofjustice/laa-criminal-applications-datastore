module Status
  class Healthcheck
    attr_reader :status, :error

    def initialize(status:, error:)
      @status = status
      @error = error
    end

    class << self
      def call
        if databases_connected?
          status = :ok
          error = nil
        else
          status = :service_unavailable
          error = 'Database Connection Error'
        end

        new(status:, error:)
      end

      def databases_connected?
        ActiveRecord::Base.connection.active?
      rescue StandardError
        false
      end
    end
  end
end
