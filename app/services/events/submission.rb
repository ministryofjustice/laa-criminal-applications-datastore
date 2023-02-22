module Events
  class Submission < BaseEvent
    def name
      'apply.submission'.freeze
    end
  end
end
