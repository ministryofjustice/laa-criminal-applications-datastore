require 'rails_helper'

describe Redacting::Unredact do
  let(:means_details) { JSON.parse(LaaCrimeSchemas.fixture(1.0, name: 'means').read) }
  let(:submitted_application) do
    JSON.parse(LaaCrimeSchemas.fixture(1.0).read).deep_merge('means_details' => means_details)
  end

  let(:crime_application) { CrimeApplication.new(submitted_application:) }
  let(:redacted_application) { crime_application.redacted_crime_application }

  # rubocop:disable RSpec/ExampleLength
  describe 'unredacting of a submitted application' do
    it 'matches the original application' do
      # redact the application
      Redacting::Redact.new(crime_application).process!

      # sanity check it has been redacted in the redacted instance
      expect(
        redacted_application.submitted_application.dig('client_details', 'applicant')
      ).to match(a_hash_including({ 'nino' => '__redacted__' }))

      # sanity check it has not been changed in the original instance
      expect(
        crime_application.submitted_application.dig('client_details', 'applicant')
      ).to match(a_hash_including({ 'nino' => 'AJ123456C' }))

      # unredact it back
      described_class.new(redacted_application).process!

      # sanity check it has been unredacted
      expect(
        redacted_application.submitted_application.dig('client_details', 'applicant')
      ).to match(
        a_hash_including({ 'nino' => 'AJ123456C' })
      )

      # sanity check the payloads are identical after the unredact
      expect(
        crime_application.submitted_application
      ).to eq(
        redacted_application.submitted_application
      )
    end
  end
  # rubocop:enable RSpec/ExampleLength
end
