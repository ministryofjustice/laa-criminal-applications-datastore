module Redacting
  module Rules
    PII_ATTRIBUTES = {
      'provider_details' => {
        redact: %w[legal_rep_first_name legal_rep_last_name legal_rep_telephone]
      },
      'client_details.applicant' => {
        # TODO: `searchable_attributes` need `first_name` and `last_name`
        # redact: %w[first_name last_name other_names nino telephone_number]
        redact: %w[other_names nino telephone_number]
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

    REDACTED_KEYWORD = '__redacted__'.freeze

    def self.all
      PII_ATTRIBUTES
    end
  end
end
