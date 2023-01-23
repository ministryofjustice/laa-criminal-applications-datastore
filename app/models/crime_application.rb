class CrimeApplication < ApplicationRecord
  has_one :return_details, dependent: :destroy

  attr_readonly :application, :submitted_at, :id

  before_validation :set_id, on: :create

  validates :status, presence: true, inclusion: { in: Types::APPLICATION_STATUSES }

  scope :by_status, ->(status) { where(status:) }
  scope :by_office, lambda { |office_code|
    where("application->'provider_details'->>'office_code' = ?", office_code)
  }

  def returned?
    !returned_at.nil?
  end

  private

  def set_id
    return unless id.nil?
    return unless application

    self.id = application.fetch('id')
  end
end
