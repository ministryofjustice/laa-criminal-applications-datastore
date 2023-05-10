module Events
  class Submission < BaseEvent
    def name
      'apply.submission'.freeze
    end

    def message
      {
        id: crime_application.id,
        submitted_at: crime_application.submitted_at,
        parent_id: crime_application.submitted_details['parent_id']
      }
    end
  end
end
