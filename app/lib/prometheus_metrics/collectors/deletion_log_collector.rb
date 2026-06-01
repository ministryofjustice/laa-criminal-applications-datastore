module PrometheusMetrics
  module Collectors
    class DeletionLogCollector < PrometheusExporter::Server::TypeCollector
      GAUGE_NAME = 'deletion_log_count'.freeze
      GAUGE_HELP = 'Total number of deletion log entries'.freeze

      def initialize
        super
        @deletion_log_gauge = PrometheusExporter::Metric::Gauge.new(
          "#{PrometheusExporter::Metric::Base.default_prefix}#{GAUGE_NAME}",
          GAUGE_HELP
        )
      end

      def type
        'deletion_log'
      end

      def collect(obj)
        @deletion_log_gauge.observe(obj['count'])
      end

      def metrics
        [@deletion_log_gauge]
      end
    end
  end
end
