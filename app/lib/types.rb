module Types
  include LaaCrimeSchemas::Types

  APPLICATION_TYPES = %w[
    initial
    post_submission_evidence
  ].freeze
  ApplicationType = String.enum(*APPLICATION_TYPES)

  APPLICATION_STATUSES = %w[
    submitted
    returned
    superseded
  ].freeze

  # The datastore does not have in_progress applications
  Types::ApplicationStatus = String.enum(*APPLICATION_STATUSES)
end
