module Events
  class Returned < BaseEvent
    # NOTE: the naming of this event is based on an older convention.
    # SNS event topics are now named to be semantically closer to our event naming convention
    # See Deleting::Archived for an example of the newer convention.
    def name
      'review.returned'.freeze
    end
  end
end
