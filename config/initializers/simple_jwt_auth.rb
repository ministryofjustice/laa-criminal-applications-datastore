require 'simple_jwt_auth'

SimpleJwtAuth.configure do |config|
  # Log level inherited from Rails logger, by default
  # `debug` in development/test and `info` in production
  config.logger = Rails.logger

  # A map of consumers of the API and their secrets
  # On kubernetes, secrets are created by terraform
  config.secrets_config = {
    'crime-apply' => ENV.fetch('API_AUTH_SECRET_APPLY', nil),
    'crime-review' => ENV.fetch('API_AUTH_SECRET_REVIEW', nil),
  }
end
