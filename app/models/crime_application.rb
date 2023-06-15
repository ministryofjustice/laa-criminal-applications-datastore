class CrimeApplication < ApplicationRecord
  include Redactable

  has_one :return_details, dependent: :destroy

  attr_readonly :submitted_application, :submitted_at, :id
  enum status: Types::ApplicationStatus.mapping
  enum review_status: Types::ReviewApplicationStatus.mapping

  before_validation :shift_payload_attributes, on: :create
  before_validation :set_overall_offence_class, on: :create

  # Exposes a `return_reason` method, used in the redacted metadata
  delegate :reason, to: :return_details, prefix: :return, allow_nil: true

  private

  def shift_payload_attributes
    return unless id.nil?
    return unless submitted_application

    self.id = submitted_application.fetch('id')
    self.submitted_at = submitted_application.fetch('submitted_at')
  end

  def set_overall_offence_class
    return unless submitted_application

    self.offence_class = Utils::OffenceClassCalculator.new(
      offences: submitted_application['case_details']['offences']
    ).offence_class
  end
end
