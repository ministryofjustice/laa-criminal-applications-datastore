require 'rails_helper'

RSpec.describe Datastore::Entities::V1::SearchResult do
  subject(:representation) do
    JSON.parse(described_class.represent(crime_application).to_json).symbolize_keys
  end

  let(:crime_application) do
    instance_double(CrimeApplication, id:, review_status:, status:, submitted_at:, reviewed_at:, submitted_application:)
  end

  let(:id) { SecureRandom.uuid }
  let(:parent_id) { SecureRandom.uuid }
  let(:submitted_at) { submitted_application['submitted_at'] }
  let(:reviewed_at) { '2023-05-22T12:42:10.907Z' }
  let(:status) { 'submitted' }
  let(:review_status) { 'assessment_completed' }

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
end
