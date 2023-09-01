module Messaging
  class EventsPublisher
    def self.publish(event)
      new.publish(event)
    end

    def publish(event)
      return false unless enabled?

      Rails.logger.debug { "==> Publishing event `#{event.name}` to SNS topic `#{topic_arn}`" }

      client.publish(
        topic_arn: topic_arn,
        message_attributes: {
          event_name: { data_type: 'String', string_value: event.name },
        },
        message: {
          event_name: event.name,
          data: event.message,
        }.to_json
      )
    end

    def enabled?
      topic_arn.present?
    end

    private

    def client
      @client ||= Aws::SNS::Client.new(
        **{
          endpoint:,
          credentials:,
          region:
        }.compact_blank
      )
    end

    def topic_arn
      ENV.fetch('EVENTS_SNS_TOPIC_ARN', nil)
    end

    def credentials
      Aws::AssumeRoleWebIdentityCredentials.new(
        role_arn: ENV.fetch('AWS_ROLE_ARN', ''),
        web_identity_token_file: ENV.fetch('AWS_WEB_IDENTITY_TOKEN_FILE', ''),
        region: region
      )
    end

    def region
      ENV.fetch('AWS_REGION', 'eu-west-2')
    end

    # Endpoint is only used to fake a local SNS service
    def endpoint
      ENV.fetch('AWS_ENDPOINT_URL', nil)
    end
  end
end
