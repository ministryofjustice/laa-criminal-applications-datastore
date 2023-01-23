class ReturnDetails < ApplicationRecord
  attr_readonly :reason_type, :crime_application_id, :details

  belongs_to :crime_application

  validates :reason_type, inclusion: { in: Types::RETURN_REASONS }
  validates :reason_text, presence: true
  validates :details, presence: true
end
