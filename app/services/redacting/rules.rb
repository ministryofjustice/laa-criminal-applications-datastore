module Redacting
  module Rules
    REDACTED_KEYWORD = '__redacted__'.freeze

    PII_ATTRIBUTES = {
      'provider_details' => {
        redact: %w[legal_rep_telephone legal_rep_last_name legal_rep_first_name provider_email]
      },
      'client_details.applicant' => {
        redact: %w[first_name last_name other_names nino arc telephone_number date_of_birth]
      },
      'client_details.applicant.home_address' => {
        redact: %w[lookup_id address_line_one address_line_two city country postcode]
      },
      'client_details.applicant.correspondence_address' => {
        redact: %w[lookup_id address_line_one address_line_two country city postcode]
      },
      'client_details.partner' => {
        redact: %w[first_name last_name other_names date_of_birth nino arc telephone_number],
        type: :object
      },
      'client_details.partner.home_address' => {
        redact: %w[lookup_id address_line_one address_line_two city country postcode]
      },
      'case_details.codefendants' => {
        redact: %w[first_name last_name],
        type: :array
      },
      'case_details' => {
        redact: %w[urn hearing_court_name hearing_date],
        type: :object
      },
      'interests_of_justice' => {
        redact: %w[reason],
        type: :array
      },
      'supporting_evidence' => {
        redact: %w[s3_object_key filename],
        type: :array
      },
      'additional_information' => {
        redact: :value,
        type: :string
      },
      'date_stamp_context' => {
        redact: %w[first_name last_name]
      },
      'means_details.income_details.employments' => {
        redact: %w[employer_name address],
        type: :array
      },
      'means_details.income_details.businesses' => {
        redact: %w[trading_name address trading_start_date additional_owners],
        type: :array
      },
      'means_details.outgoings_details.outgoings' => {
        redact: %w[metadata],
        type: :array
      },
      'means_details.capital_details' => {
        redact: %w[premium_bonds_holder_number partner_premium_bonds_holder_number]
      },
      'means_details.capital_details.savings' => {
        redact: %w[sort_code account_number],
        type: :array
      },
      'means_details.capital_details.national_savings_certificates' => {
        redact: %w[holder_number certificate_number],
        type: :array
      },
      'means_details.capital_details.investments' => {
        redact: %w[description],
        type: :array
      },
      'means_details.capital_details.properties' => {
        redact: %w[address property_owners],
        type: :array
      }
    }.freeze

    def self.pii_attributes
      PII_ATTRIBUTES
    end
  end
end
