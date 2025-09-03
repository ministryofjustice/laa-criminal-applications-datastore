module Reviewing
  class Event < RailsEventStore::Event; end
  class SentBack < Event; end
  class Completed < Event; end
end
