class RedactedCrimeApplication < ApplicationRecord
  belongs_to :crime_application

  attr_readonly :id, :submitted_application
end
