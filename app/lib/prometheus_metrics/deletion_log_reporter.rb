module PrometheusMetrics
  class DeletionLogReporter
    def self.report(count)
      client = PrometheusExporter::Client.default

      client.send_json(
        type: 'deletion_log',
        count: count
      )
    rescue StandardError => e
      Rails.logger.warn("Failed to report deletion log metric: #{e.message}")
    end
  end
end
