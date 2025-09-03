module Deleting
  class Deletable
    class << self
      def call(_business_reference)
        true
          # TODO: work out how we want to do this part
          #
          # RailsEventStore::Projection
          .from_stream(streams)
          .init(-> { [] })
          .when(
            ApplicationHistory::EVENT_TYPES,
            lambda { |state, event|
              state << ApplicationHistoryItem.from_event(event, application)
            }
          ).run(Rails.application.config.event_store).sort_by(&:timestamp).reverse
      end
    end
  end
end
