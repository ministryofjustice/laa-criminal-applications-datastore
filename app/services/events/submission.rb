module Events
  class Submission < BaseEvent
    def name
      'apply.submission'.freeze
    end

    def message
      {
        id: crime_application.id,
        submitted_at: crime_application.submitted_at
      }
    end
  end
end
