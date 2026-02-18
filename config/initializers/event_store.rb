Rails.configuration.to_prepare do
  event_store = Rails.configuration.event_store = RailsEventStore::JSONClient.new

  Deleting::Configuration.call(event_store)
end
