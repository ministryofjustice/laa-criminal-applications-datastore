module Applying
  class Event < RailsEventStore::Event; end
  class DraftCreated < Event; end
  class DraftUpdated < Event; end
  class DraftDeleted < Event; end
  class Submitted < Event; end
end
