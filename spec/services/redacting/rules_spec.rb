require 'rails_helper'

describe Redacting::Rules do
  describe '.pii_attributes' do
    # Sanity check only, more thorough tests part of `redact_spec.rb`
    it 'has the expected paths' do
      expect(
        described_class.pii_attributes.keys
      ).to match_array(
        %w[
          provider_details
          client_details.applicant
          client_details.applicant.correspondence_address
          client_details.applicant.home_address
          case_details.codefendants
          interests_of_justice
          supporting_evidence
        ]
      )
    end
  end
end
