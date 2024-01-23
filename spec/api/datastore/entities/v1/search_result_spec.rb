require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
#
RSpec.describe Datastore::Entities::V1::SearchResult do
  subject(:representation) do
    JSON.parse(described_class.represent(crime_application).to_json).symbolize_keys
  end

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      id:,
      review_status:,
      status:,
      submitted_at:,
      reviewed_at:,
      submitted_application:,
      work_stream:,
      return_reason:,
      return_details:,
      office_code:
    )
  end

  let(:id) { SecureRandom.uuid }
  let(:parent_id) { SecureRandom.uuid }
  let(:submitted_at) { submitted_application['submitted_at'] }
  let(:reviewed_at) { '2023-05-22T12:42:10.907Z' }
  let(:status) { 'submitted' }
  let(:review_status) { 'assessment_completed' }
  let(:return_reason) { 'evidence_issue' }
  let(:return_details) { { 'details' => 'There was an issue with the uploaded evidence' } }
  let(:office_code) { 'XYZ123' }
  let(:work_stream) { 'criminal_applications_team' }
  let(:case_type) { 'summary_only' }
  let(:application_type) { 'initial' }
  let(:means_passport) { ['on_benefit_check'] }

  let(:submitted_application) do
    LaaCrimeSchemas.fixture(1.0) { |json| json.merge('parent_id' => parent_id) }
  end

  it 'represents submitted_at in is8601' do
    expect(representation.fetch(:submitted_at)).to eq submitted_at
  end

  it 'represents reviewed_at in is8601' do
    expect(representation.fetch(:reviewed_at)).to eq reviewed_at
  end

  it 'represents the status' do
    expect(representation.fetch(:status)).to eq status
  end

  it 'represents the review_status' do
    expect(representation.fetch(:review_status)).to eq review_status
  end

  it 'represents id as resource_id' do
    expect(representation.fetch(:resource_id)).to eq id
  end

  it 'represents the parent_id' do
    expect(representation.fetch(:parent_id)).to eq parent_id
  end

  it 'represents the reference' do
    expect(representation.fetch(:reference)).to eq 6_000_001
  end

  it 'represents the applicant_name' do
    expect(representation.fetch(:applicant_name)).to eq 'Kit Pound'
  end

  it 'represents the work_stream' do
    expect(representation.fetch(:work_stream)).to eq 'criminal_applications_team'
  end

  it 'represents the office_code' do
    expect(representation.fetch(:office_code)).to eq office_code
  end

  it 'represents the return_reason' do
    expect(representation.fetch(:return_reason)).to eq 'evidence_issue'
  end

  it 'represents the return_details' do
    expect(representation.fetch(:return_details)).to eq 'There was an issue with the uploaded evidence'
  end

  context 'when return details are empty' do
    let(:return_details) { {} }
    let(:return_reason) { nil }

    it 'represents details and reason as nil' do
      expect(representation.fetch(:return_reason)).to be_nil
      expect(representation.fetch(:return_details)).to be_nil
    end
  end

  it 'represents the case_type' do
    expect(representation.fetch(:case_type)).to eq 'appeal_to_crown_court'
  end

  it 'represents the application_type' do
    expect(representation.fetch(:application_type)).to eq 'initial'
  end

  it 'represents the means_passport' do
    expect(representation.fetch(:means_passport)).to eq ['on_benefit_check']
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
