require 'simple_jwt_auth'

Rails.application.config.to_prepare do
  SimpleJwtAuth.configure do |config|
    # Use same logger from Grape API
    config.logger = Datastore::Base.logger

    # Log level inherited from Rails logger, by default
    # `debug` in development/test and `info` in production
    config.logger.level = Rails.logger.level

    # A map of consumers of the API and their secrets
    # On kubernetes, secrets are created by terraform
    config.secrets_config = {
      'crime-apply' => ENV.fetch('API_AUTH_SECRET_APPLY', nil),
      'crime-apply-preprod' => ENV.fetch('API_AUTH_SECRET_APPLY_PREPROD', nil),
      'crime-review' => ENV.fetch('API_AUTH_SECRET_REVIEW', nil),
      'maat-adapter' => ENV.fetch('API_AUTH_SECRET_MAAT_ADAPTER', nil),
      # MAAT has more non-prod environments than we have, but
      # they are pointing these non-prod to our staging datastore
      'maat-adapter-dev' => ENV.fetch('API_AUTH_SECRET_MAAT_ADAPTER_DEV', nil),
      'maat-adapter-uat' => ENV.fetch('API_AUTH_SECRET_MAAT_ADAPTER_UAT', nil),
    }
  end
end
