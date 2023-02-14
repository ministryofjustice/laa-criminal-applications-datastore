require 'simple_jwt_auth'

SimpleJwtAuth.configure do |config|
  config.logger = Logger.new(STDOUT)
  config.logger.level = Logger::DEBUG

  # A map of consumers of the API and their secrets
  # On kubernetes, secrets are created by terraform
  config.secrets_config = {
    'crime-apply' => ENV.fetch('API_AUTH_SECRET_APPLY', nil),
    'crime-review' => ENV.fetch('API_AUTH_SECRET_REVIEW', nil),
  }
end
