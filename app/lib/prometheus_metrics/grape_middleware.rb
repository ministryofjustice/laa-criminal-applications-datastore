module PrometheusMetrics
  require 'prometheus_exporter/middleware'

  class GrapeMiddleware < PrometheusExporter::Middleware
    def default_labels(env, result)
      return super unless _api_request?(env)

      {
        controller: "(api:#{_api_method(env).downcase})",
        action: _api_action(env),
      }
    rescue StandardError
      super
    end

    def custom_labels(env)
      return unless _api_request?(env)

      {
        api_version: _api_version(env),
        api_method: _api_method(env),
      }
    rescue StandardError
      nil
    end

    private

    def _api_request?(env)
      env['api.endpoint'].present?
    end

    def _api_action(env)
      env['api.endpoint'].namespace
    end

    def _api_method(env)
      env['api.endpoint'].options[:method].first
    end

    def _api_version(env)
      env['api.version'] || 'n/a'
    end
  end
end
