module GrapeLogging
  module Loggers
    class JwtIssuer < GrapeLogging::Loggers::Base
      def parameters(request, _)
        { issuer: request.env['grape_jwt.payload'].try(:dig, 'iss') }
      end
    end
  end
end
