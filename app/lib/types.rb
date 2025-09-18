module Types
  include LaaCrimeSchemas::Types

  APPLICATION_STATUSES = %w[
    submitted
    returned
    superseded
  ].freeze

  # The datastore does not have in_progress applications
  Types::ApplicationStatus = String.enum(*APPLICATION_STATUSES)

  DELETION_REASONS = %w[
    provider_action
    retention_rule
  ].freeze

  Types::DeletionReason = String.enum(*DELETION_REASONS)
end
