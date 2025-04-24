require 'rails_helper'

describe Redacting::Rules do
  describe '.pii_attributes' do
    # Sanity check only, more thorough tests part of `redact_spec.rb`
    let(:expected_paths) do
      %w[
        provider_details
        client_details.applicant
        client_details.applicant.correspondence_address
        client_details.applicant.home_address
        client_details.partner
        case_details.codefendants
        case_details
        interests_of_justice
        supporting_evidence
        additional_information
        date_stamp_context
        means_details.capital_details
        means_details.capital_details.properties.address
        means_details.capital_details.properties.property_owners
      ]
    end

    it 'has the expected paths' do
      expect(described_class.pii_attributes.keys).to match_array(expected_paths)
    end
  end
end
