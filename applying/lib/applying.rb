module Applying
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

  class DraftCreated < Event; end
  class DraftUpdated < Event; end
  class DraftDeleted < Event; end
  class Submitted < Event; end
end
