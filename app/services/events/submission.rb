module Events
  class Submission < BaseEvent
    # Note: the naming of this event is based on an older convention.
    # SNS event topics are now named to be semantically closer to our event naming convention
    # See Applying::Archived for an example of the newer convention.
    def name
      'apply.submission'.freeze
    end

    def message
      {
        id: crime_application.id,
        submitted_at: crime_application.submitted_at,
        parent_id: crime_application.submitted_application['parent_id'],
        work_stream: crime_application.work_stream,
        application_type: crime_application.application_type,
        reference: crime_application.reference
      }
    end
  end
end
