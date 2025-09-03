module Deciding
  class Event < RailsEventStore::Event; end
  class MaatRecordCreated < Event; end
end
