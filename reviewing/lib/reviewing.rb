module Reviewing
  class Event < RailsEventStore::Event
    def self.from_application(crime_application)
      new(
        data: {
          entity_id: crime_application.id,
          entity_type: crime_application.application_type,
          business_reference: crime_application.reference
        }
      )
    end
  end

  class SentBack < Event; end
  class Completed < Event; end
end
