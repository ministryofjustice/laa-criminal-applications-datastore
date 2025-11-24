module Types
  include LaaCrimeSchemas::Types

  APPLICATION_STATUSES = %w[
    submitted
    returned
    superseded
  ].freeze

  # The datastore does not have in_progress applications
  Types::ApplicationStatus = String.enum(*APPLICATION_STATUSES)

  RECORD_TYPES = %w[
    document
    application
  ].freeze

  Types::RecordType = String.enum(*RECORD_TYPES)

  RECORD_SOURCE = %w[
    amazon_s3
    crime_apply
    criminal_applications_datastore
  ].freeze

  Types::RecordSource = String.enum(*RECORD_SOURCE)

  DELETION_REASONS = %w[
    provider_action
    retention_rule
  ].freeze

  Types::DeletionReason = String.enum(*DELETION_REASONS)

  DELETION_EXEMPTION_REASONS = %w[
    deleted_in_error
    restricted_by_user
    under_investigation
  ].freeze

  Types::DeletionExemptionReason = String.enum(*DELETION_EXEMPTION_REASONS)
end
