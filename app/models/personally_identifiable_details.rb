class PersonallyIdentifiableDetails < ApplicationRecord
  belongs_to :crime_application

  attr_readonly :id, :protected_details
end
