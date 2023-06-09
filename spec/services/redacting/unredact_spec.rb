require 'rails_helper'

describe Redacting::Unredact do
  let(:submitted_application) { JSON.parse(LaaCrimeSchemas.fixture(1.0).read) }

  let(:app_a) { CrimeApplication.new(submitted_application:) } # to be redacted
  let(:app_b) { CrimeApplication.new(submitted_application:) } # remains unredacted

  describe 'unredacting of a submitted application' do
    it 'matches the original application' do
      # redact one application
      Redacting::Redact.new(app_a).process!

      # sanity check it has been redacted
      expect(
        app_a.submitted_application.dig('client_details', 'applicant')
      ).to match(a_hash_including({ 'nino' => '__redacted__' }))

      # unredact it back
      described_class.new(app_a).process!

      # sanity check it has been unredacted
      expect(
        app_a.submitted_application.dig('client_details', 'applicant')
      ).to match(
        a_hash_including({ 'nino' => 'AJ123456C' })
      )

      # sanity check these are indeed the original details
      expect(
        app_a.submitted_application.dig('client_details', 'applicant')
      ).to eq(
        app_b.submitted_application.dig('client_details', 'applicant')
      )
    end
  end
end
