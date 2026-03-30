class Decision < ApplicationRecord
  belongs_to :crime_application

  after_commit { crime_application.recompute_searchable_text }
end
