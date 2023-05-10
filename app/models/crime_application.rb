class CrimeApplication < ApplicationRecord
  has_one :return_details, dependent: :destroy

  attr_readonly :submitted_details, :submitted_at, :id
  enum status: Types::ApplicationStatus.mapping
  enum review_status: Types::ReviewApplicationStatus.mapping

  before_validation :shift_payload_attributes, on: :create
  before_validation :set_overall_offence_class, on: :create

  scope :by_status, ->(status) { where(status:) }
  scope :by_office, lambda { |office_code|
    where("submitted_details->'provider_details'->>'office_code' = ?", office_code)
  }

  private

  def shift_payload_attributes
    return unless id.nil?
    return unless submitted_details

    self.id = submitted_details.fetch('id')
    self.submitted_at = submitted_details.fetch('submitted_at')
  end

  def set_overall_offence_class
    return unless id.nil?
    return unless submitted_details

    Rails.logger.debug submitted_details
    offences = submitted_details['case_details']['offences']
    self.offence_class = Utils::OffenceClassCalculator.new(offences:).offence_class
  end
end
