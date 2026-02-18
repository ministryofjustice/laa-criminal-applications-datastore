module Events
  class Archived < BaseEvent
    def name
      'Deleting::Archived'.freeze
    end

    def message
      {
        id: crime_application.id,
        archived_at: crime_application.archived_at,
        application_type: crime_application.application_type,
        reference: crime_application.reference
      }
    end
  end
end
