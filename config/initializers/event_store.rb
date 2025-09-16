Rails.configuration.to_prepare do
  Rails.configuration.event_store = RailsEventStore::JSONClient.new
end
