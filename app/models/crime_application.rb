class CrimeApplication < ApplicationRecord
  include Redactable

  attr_readonly :submitted_application, :submitted_at, :id
  enum :status, Types::ApplicationStatus.mapping
  enum :review_status, Types::ReviewApplicationStatus.mapping

  before_validation :shift_payload_attributes, on: :create
  before_validation :set_overall_offence_class, :set_work_stream, on: :create
  before_save :copy_first_court_hearing_name

  has_many :decisions, dependent: :destroy

  scope :consumer_scope, lambda { |consumer|
    case consumer
    when 'crime-apply'
      where(archived_at: nil)
    else
      all
    end
  }

  scope :latest, lambda { |reference|
    where(reference:).order(submitted_at: :desc).limit(1)
  }

  def application_type
    submitted_application.fetch('application_type')
  end

  def archived?
    archived_at.present?
  end

  private

  def shift_payload_attributes
    return unless id.nil?
    return unless submitted_application

    self.id = submitted_application.fetch('id')
    self.submitted_at = submitted_application.fetch('submitted_at')
  end

  def set_overall_offence_class
    return unless submitted_application
    return if post_submission_evidence?

    self.offence_class = Utils::OffenceClassCalculator.new(
      offences: submitted_application['case_details']['offences']
    ).offence_class
  end

  # Replicate the 'hearing_court_name' into 'first_court_hearing_name' to maintain
  # data consistency for reporting and consuming services
  def copy_first_court_hearing_name
    return if submitted_application.blank?
    return if post_submission_evidence?

    case_details = submitted_application.fetch('case_details')
    return if case_details['first_court_hearing_name'].present?
    return if case_details['is_first_court_hearing'] == Types::FirstHearingAnswerValues['no']

    case_details['first_court_hearing_name'] = case_details['hearing_court_name']
  end

  def set_work_stream
    return unless submitted_application

    if post_submission_evidence?
      parent_app = CrimeApplication.find(submitted_application['parent_id'])
      self.work_stream = parent_app.work_stream
    else
      self.work_stream = Utils::WorkStreamCalculator.new(
        submitted_application_struct
      ).work_stream
    end
  end

  def submitted_application_struct
    @submitted_application_struct ||= LaaCrimeSchemas::Structs::CrimeApplication.new(
      submitted_application
    )
  end

  def post_submission_evidence?
    application_type == Types::ApplicationType['post_submission_evidence']
  end
end
