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
        subject: event.name,
        message: event.message.to_json,
        message_attributes: {
          event_name: { data_type: 'String', string_value: event.name },
        }
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
          access_key_id:,
          secret_access_key:,
          region:
        }.compact_blank
      )
    end

    def topic_arn
      ENV.fetch('EVENTS_SNS_TOPIC_ARN', nil)
    end

    def access_key_id
      ENV.fetch('EVENTS_SNS_TOPIC_KEY_ID', nil)
    end

    def secret_access_key
      ENV.fetch('EVENTS_SNS_TOPIC_SECRET', nil)
    end

    def region
      ENV.fetch('EVENTS_SNS_TOPIC_REGION', 'eu-west-2')
    end

    # Endpoint is only used to fake a local SNS service
    def endpoint
      ENV.fetch('LOCAL_SNS_FAKER_URL', nil)
    end
  end
end
