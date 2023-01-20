class ReturnDetails < ApplicationRecord
  belongs_to :crime_application

  validates :reason_type, inclusion: { in: Types::RETURN_REASONS }
  validates :reason_text, presence: true
  validates :details, presence: true
end
