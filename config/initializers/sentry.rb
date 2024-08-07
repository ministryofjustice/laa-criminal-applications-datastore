require 'active_support/parameter_filter'

Rails.application.config.to_prepare do
  # Sentry is enabled if SENTRY_DSN environment variable is set
  Sentry.init do |config|
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]
    config.environment = HostEnv.env_name

    # to enable performance
    config.traces_sample_rate = 0.05

    # to enable profiling
    config.profiles_sample_rate = 0.05
    config.rails.register_error_subscriber = true

    # Filtering
    # https://docs.sentry.io/platforms/ruby/guides/rails/configuration/filtering/

    params_filter = ActiveSupport::ParameterFilter.new(
      Rails.application.config.filter_parameters
    )

    config.before_send = lambda do |event, _hint|
      params_filter.filter(event.to_hash)
    end
  end
end
