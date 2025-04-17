module Redacting
  module Rules
    REDACTED_KEYWORD = '__redacted__'.freeze

    PII_ATTRIBUTES = {
      'provider_details' => {
        redact: %w[legal_rep_telephone]
      },
      'client_details.applicant' => {
        redact: %w[first_name last_name other_names nino arc telephone_number date_of_birth]
      },
      'client_details.applicant.home_address' => {
        redact: %w[lookup_id address_line_one address_line_two]
      },
      'client_details.applicant.correspondence_address' => {
        redact: %w[lookup_id address_line_one address_line_two]
      },
      'client_details.partner' => {
        redact: %w[first_name last_name other_names date_of_birth nino],
        type: :object
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
      'means_details' => {
        redact: %w[
          income_details.income_payments.amount
          income_details.income_benefits.amount
          income_details.employment_type
          income_details.partner_employment_type
          capital_details.premium_bonds_total_value
          capital_details.partner_premium_bonds_total_value
          capital_details.trust_fund_amount_held
          capital_details.trust_fund_yearly_dividend
          capital_details.partner_trust_fund_amount_held
          capital_details.partner_trust_fund_yearly_dividend
          outgoings_details.outgoings.amount
        ]
      }

    }.freeze

    def self.pii_attributes
      PII_ATTRIBUTES
    end
  end
end
