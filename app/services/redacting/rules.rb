module Redacting
  module Rules
    REDACTED_KEYWORD = '__redacted__'.freeze

    PII_ATTRIBUTES = {
      'provider_details' => {
        redact: %w[legal_rep_first_name legal_rep_last_name legal_rep_telephone]
      },
      'client_details.applicant' => {
        redact: %w[first_name last_name other_names nino telephone_number]
      },
      'client_details.applicant.home_address' => {
        redact: %w[lookup_id address_line_one address_line_two]
      },
      'client_details.applicant.correspondence_address' => {
        redact: %w[lookup_id address_line_one address_line_two]
      },
      'case_details.codefendants' => {
        redact: %w[first_name last_name],
        type: :array # [{}, {}, ...]
      },
    }.freeze

    # Additional top level attributes to propagate from the
    # unredacted table to the redacted one
    METADATA_ATTRIBUTES = [
      :status,
      :returned_at,
      :reviewed_at,
      :review_status,
      :offence_class,
    ].freeze

    def self.pii_attributes
      PII_ATTRIBUTES
    end

    def self.metadata_attributes
      METADATA_ATTRIBUTES
    end
  end
end
