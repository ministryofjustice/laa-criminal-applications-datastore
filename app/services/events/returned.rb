module Events
  class Returned < BaseEvent
    def name
      'review.returned'.freeze
    end
  end
end
