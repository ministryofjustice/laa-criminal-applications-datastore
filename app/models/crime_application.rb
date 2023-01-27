class CrimeApplication < ApplicationRecord
  has_one :return_details, dependent: :destroy

  attr_readonly :application, :submitted_at, :id
  enum status: Types::ApplicationStatus.mapping

  before_validation :shift_payload_attributes, on: :create

  scope :by_status, ->(status) { where(status:) }
  scope :by_office, lambda { |office_code|
    where("application->'provider_details'->>'office_code' = ?", office_code)
  }

  private

  def shift_payload_attributes
    return unless id.nil?
    return unless application

    self.id = application.fetch('id')
    self.submitted_at = application.fetch('submitted_at')
  end
end
