module Status
  class Healthcheck
    attr_reader :status, :error

    def initialize(status:, error:)
      @status = status
      @error = error
    end

    class << self
      def call
        if database_connected?
          status = :ok
          error = nil
        else
          status = :service_unavailable
          error = 'Database Connection Error'
        end

        new(status:, error:)
      end

      def database_connected?
        ActiveRecord::Base.connection.active?
      rescue StandardError => e
        Rails.logger.error(e)
        Sentry.capture_exception(e)

        false
      end
    end
  end
end
