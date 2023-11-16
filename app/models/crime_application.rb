class CrimeApplication < ApplicationRecord
  include Redactable

  attr_readonly :submitted_application, :submitted_at, :id
  enum status: Types::ApplicationStatus.mapping
  enum review_status: Types::ReviewApplicationStatus.mapping

  before_validation :shift_payload_attributes, on: :create
  before_validation :set_overall_offence_class, :set_work_stream, on: :create
  before_save :copy_first_court_hearing_name

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

  # Replicate the 'hearing_court_name' into 'first_court_hearing_name' to maintain
  # data consistency for reporting and consuming services
  def copy_first_court_hearing_name
    return if submitted_application.blank?

    case_details = submitted_application.fetch('case_details')
    return if case_details['first_court_hearing_name'].present?
    return if case_details['is_first_court_hearing'] == Types::FirstHearingAnswerValues['no']

    case_details['first_court_hearing_name'] = case_details['hearing_court_name']
  end

  def set_work_stream
    return unless submitted_application

    first_court_hearing_name = (submitted_application['case_details']['first_court_hearing_name'].presence ||
                                submitted_application['case_details']['hearing_court_name'])

    self.work_stream = Utils::WorkStreamCalculator.new(
      first_court_name: first_court_hearing_name
    ).work_stream
  end
end
