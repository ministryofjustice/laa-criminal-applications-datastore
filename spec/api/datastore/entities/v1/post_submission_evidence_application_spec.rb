require 'rails_helper'

RSpec.describe Datastore::Entities::V1::PostSubmissionEvidenceApplication do
  subject(:representation) do
    JSON.parse(described_class.represent(crime_application).to_json)
  end

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      id: SecureRandom.uuid,
      status: Types::ApplicationStatus['submitted'],
      submitted_at: 3.days.ago,
      reviewed_at: nil,
      returned_at: 3.days.ago - 1.hour,
      review_status: Types::ReviewApplicationStatus['application_received'],
      return_details: { reason: nil, details: nil, returned_at: nil },
      offence_class: Types::OffenceClass['C'],
      work_stream: Types::WorkStreamType['criminal_applications_team'],
      submitted_application: submitted_application,
      soft_deleted_at: nil
    )
  end

  let(:submitted_application) do
    LaaCrimeSchemas.fixture(1.0, name: 'post_submission_evidence') do |json|
      json.merge('parent_id' => SecureRandom.uuid)
    end
  end

  context 'when retrieved from the submitted details' do
    it 'represents the provider details' do
      expect(representation.fetch('provider_details')).to eq submitted_application.fetch('provider_details')
    end

    it 'represents the client details' do
      expect(representation.fetch('client_details')).to eq submitted_application.fetch('client_details')
    end

    it 'represents the parent_id' do
      expect(representation.fetch('parent_id')).to eq submitted_application.fetch('parent_id')
    end

    it 'represents the reference' do
      expect(representation.fetch('reference')).to eq submitted_application.fetch('reference')
    end

    it 'represents the application type' do
      expect(representation.fetch('application_type')).to eq submitted_application.fetch('application_type')
    end

    it 'represents the id' do
      expect(representation.fetch('id')).to eq submitted_application.fetch('id')
    end

    it 'represents created_at' do
      expect(representation.fetch('created_at')).to eq submitted_application.fetch('created_at')
    end

    it 'represents the supporting evidence' do
      expect(representation.fetch('supporting_evidence')).to eq submitted_application.fetch('supporting_evidence')
    end

    it 'represents the evidence details', skip: 'CRIMAPP-798' do
      expect(representation.fetch('evidence_details')).to eq submitted_application.fetch('evidence_details')
    end
  end

  context 'when retrieved from the database' do
    it 'represents submitted_at' do
      expect(representation.fetch('submitted_at')).to eq crime_application.submitted_at.iso8601(3)
    end

    it 'represents the status' do
      expect(representation.fetch('status')).to eq crime_application.status
    end

    it 'represents the review_status' do
      expect(representation.fetch('review_status')).to eq crime_application.review_status
    end
  end
end
