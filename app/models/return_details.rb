class ReturnDetails < ApplicationRecord
  attr_readonly :reason, :crime_application_id, :details

  belongs_to :crime_application

  validates :reason, inclusion: { in: Types::RETURN_REASONS }
  validates :details, presence: true
end
