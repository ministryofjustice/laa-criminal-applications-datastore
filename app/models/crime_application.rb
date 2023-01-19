class CrimeApplication < ApplicationRecord
  attr_readonly :application, :submitted_at, :id

  before_validation :set_attributes_from_payload, on: :create

  validates :status, presence: true, inclusion: { in: Types::APPLICATION_STATUSES }

  scope :by_status, ->(status) { where(status:) }
  scope :by_office, lambda { |office_code|
    where("application->'provider_details'->>'office_code' = ?", office_code)
  }

  private

  # rubocop:disable Metrics/AbcSize
  def set_attributes_from_payload
    return unless id.nil?
    return unless application

    assign_attributes(
      id: application.fetch('id'),
      status: application.fetch('status'),
      submitted_at: application.fetch('submitted_at'),
      returned_at: application.fetch('returned_at', nil),
      searchable_text: application.fetch('searchable_text', nil),
      review_completed_at: application.fetch('review_completed_at', nil),
      review_received_at: application.fetch('review_received_at', nil),
      return_reason: application.fetch('return_reason', nil)
    )
  end
  # rubocop:enable Metrics/AbcSize
end
