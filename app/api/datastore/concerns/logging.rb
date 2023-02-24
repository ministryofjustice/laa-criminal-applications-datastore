require 'grape_logging'

module Datastore
  module Concerns
    module Logging
      extend ActiveSupport::Concern

      # :nocov:
      included do
        if Rails.env.production?
          insert_before(
            Grape::Middleware::Error,
            GrapeLogging::Middleware::RequestLogger,
            formatter: GrapeLogging::Formatters::Logstash.new,
            include: [
              # To log IP and UserAgent, uncomment next line
              # GrapeLogging::Loggers::ClientEnv.new,
              GrapeLogging::Loggers::FilterParameters.new,
              GrapeLogging::Loggers::JwtIssuer.new,
            ]
          )
        end
      end
      # :nocov:
    end
  end
end
