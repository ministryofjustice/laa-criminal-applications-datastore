Rails.configuration.to_prepare do
  event_store = Rails.configuration.event_store = RailsEventStore::Client.new

end


