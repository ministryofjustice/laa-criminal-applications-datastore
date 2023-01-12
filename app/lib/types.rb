module Types
  include LaaCrimeSchemas::Types
  #
  # TODO: replace with types from gem
  #
  REVIEW_APPLICATION_STATUSES = %w[
    application_received returned_to_provider ready_for_assessment
  ].freeze

  APPLICATION_STATUSES = %w[
    submitted returned
  ].freeze
end
