module Deciding
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

  class MaatRecordCreated < Event
    def self.from_application(crime_application:, maat_id:)
      data = super(crime_application).data
      data[:maat_id] = maat_id
      new(data:)
    end
  end

  class Decided < Event
    def self.from_application(crime_application:, decision:)
      data = super(crime_application).data
      data[:decision_id] = decision.id
      data[:overall_decision] = decision.overall_result
      new(data:)
    end
  end
end
