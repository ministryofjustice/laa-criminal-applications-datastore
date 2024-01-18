module Types
  include LaaCrimeSchemas::Types

  APPLICATION_TYPES = %w[
    initial
    post_submission_evidence
  ].freeze
  ApplicationType = String.enum(*APPLICATION_TYPES)
end
