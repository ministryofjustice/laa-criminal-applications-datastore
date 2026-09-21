class SlipstreamAuditSelectionOutcome < ApplicationRecord
  STATUSES = %w[not_selected confirmed withdrawn].freeze

  scope :with_status, ->(status) { where(status:) }
  scope :submitted_between, ->(range) { where(submitted_at: range) }
end
