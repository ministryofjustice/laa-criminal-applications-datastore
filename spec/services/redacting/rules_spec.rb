require 'rails_helper'

describe Redacting::Rules do
  describe '.pii_attributes' do
    let(:expected_paths) do
      %w[
        provider_details
        client_details.applicant
        client_details.applicant.correspondence_address
        client_details.applicant.home_address
        client_details.applicant.date_of_birth
        client_details.partner
        case_details.codefendants
        case_details
        interests_of_justice
        supporting_evidence
        additional_information
        date_stamp_context
        means_details
      ]
    end

    it 'has the expected paths' do
      expect(described_class.pii_attributes.keys).to match_array(expected_paths)
    end
  end
end
