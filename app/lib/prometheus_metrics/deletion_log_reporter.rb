module PrometheusMetrics
  class DeletionLogReporter
    REPORT_INTERVAL = ENV.fetch('DELETION_LOG_REPORT_INTERVAL', 60).to_i # seconds

    def self.report(count)
      client = PrometheusExporter::Client.default

      client.send_json(
        type: 'deletion_log',
        count: count
      )
    rescue StandardError => e
      Rails.logger.warn("Failed to report deletion log metric: #{e.message}")
    end

    # :nocov:
    def self.start
      Rails.logger.info "[DeletionLogReporter] Starting background reporter (interval: #{REPORT_INTERVAL}s)"

      Thread.new do
        loop do
          report(DeletionEntry.count)
          sleep REPORT_INTERVAL
        rescue StandardError => e
          Rails.logger.warn("DeletionLogReporter error: #{e.message}")
          sleep REPORT_INTERVAL
        end
      end
    end
    # :nocov:
  end
end
