module Deciding
  class Event < RailsEventStore::Event; end
  class MaatRecordCreated < Event; end
  class Decided < Event; end
end
