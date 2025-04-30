class RedactedCrimeApplication < ApplicationRecord
  belongs_to :crime_application

  attr_readonly :id, :status
end
