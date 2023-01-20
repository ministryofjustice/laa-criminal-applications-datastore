module Types
  include LaaCrimeSchemas::Types

  #
  # TODO Get Return Types from LaaCrimeSchemas::Types once types have been added.
  #
  RETURN_REASONS = %w[
    clarification_required
    evidence_issue
    duplicate_application
    case_concluded
    provider_request
  ].freeze

  ReturnReason = String.enum(*RETURN_REASONS)
end
