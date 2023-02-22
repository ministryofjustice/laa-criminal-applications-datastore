module Events
  class BaseEvent
    attr_reader :crime_application

    def initialize(crime_application)
      @crime_application = crime_application
    end

    # :nocov:
    def name
      raise 'implement in subclasses'
    end
    # :nocov:

    # Can be overridden in subclasses if required
    def message
      { id: crime_application.id }
    end

    # Convenience method as currently we only have
    # one SNS topic and one publisher
    def publish
      Messaging::EventsPublisher.publish(self)
    end
  end
end
