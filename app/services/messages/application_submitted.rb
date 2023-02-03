module Messages
  class ApplicationSubmitted
    attr_reader :crime_application

    def initialize(crime_application)
      @crime_application = crime_application
    end

    def publish
      Rails.logger.info "==> Publishing application #{crime_application.id}"

      sqs_client.send_message(
        queue_url:,
        message_body:,
      )
    end

    private

    def queue_url
      ENV.fetch('SQS_MAAT_QUEUE_URL')
    end

    def message_body
      crime_application.application.to_json
    end

    # The Shoryuken AWS SQS client is already configured,
    # so we can use it, but we can also instantiate ours.
    def sqs_client
      Shoryuken.sqs_client
    end
  end
end
