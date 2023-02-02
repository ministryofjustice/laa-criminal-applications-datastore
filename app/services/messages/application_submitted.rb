module Messages
  class ApplicationSubmitted
    attr_reader :crime_application

    def initialize(crime_application)
      @crime_application = crime_application
    end

    def process
      Rails.logger.info "==> Publishing application #{crime_application.id}"

      sqs_client.send_message(
        queue_url:,
        message_body:,
      )
    end

    private

    # TODO: this is an early PoC, we can either instantiate
    # a new client, or use the Shoryuken configured one,
    # tho we incur in a bit of coupling.
    def sqs_client
      Shoryuken.sqs_client
    end

    def queue_url
      ENV.fetch('SQS_MAAT_QUEUE_URL')
    end

    def message_body
      crime_application.application.to_json
    end
  end
end
