require 'laa_crime_schemas'

class CrimeApplication < ApplicationRecord
  include Redactable

  attr_readonly :submitted_application, :submitted_at, :id
  enum status: Types::ApplicationStatus.mapping
  enum review_status: Types::ReviewApplicationStatus.mapping

  before_validation :shift_payload_attributes, on: :create
  before_validation :set_overall_offence_class, on: :create
  before_validation :copy_first_court_name, on: :save

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

  # Replicate the 'hearing_court_name' into 'first_court_hearing_name' even though they
  # are assumed to be the same when `is_first_court_hearing = yes`
  def copy_first_court_name
    return if first_court_name.present?
    return if is_first_court_hearing != LaaCrimeSchemas::Types::FirstHearingAnswerValues['yes']

    self.first_court_name = hearing_court_name
  end
end
