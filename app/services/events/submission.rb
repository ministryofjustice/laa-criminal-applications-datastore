module Events
  class Submission < BaseEvent
    def name
      'apply.submission'.freeze
    end

    def message
      {
        id: crime_application.id,
        submitted_at: crime_application.submitted_at,
        parent_id: crime_application.submitted_application['parent_id'],
        work_stream: crime_application.work_stream,
        application_type: crime_application.application_type
      }
    end
  end
end
