require 'rails_helper'

RSpec.describe Datastore::Entities::V1::CrimeApplication do
  subject(:representation) do
    JSON.parse(described_class.represent(crime_application).to_json)
  end

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      id:,
      status:,
      submitted_at:,
      reviewed_at:,
      returned_at:,
      return_details:,
      offence_class:,
      submitted_application:
    )
  end

  let(:id) { SecureRandom.uuid }
  let(:submitted_at) { 3.days.ago.to_json }
  let(:reviewed_at) { nil }
  let(:status) { Types::ApplicationStatus['submitted'] }
  let(:offence_class) { Types::OffenceClass['C'] }
  let(:case_details) { { offence_class: } }
  let(:returned_at) { 3.days.ago.to_json }
  let(:return_details) do
    {
      reason: nil,
      details: nil,
      returned_at: nil
    }
  end

  let(:submitted_application) do
    JSON.parse(LaaCrimeSchemas.fixture(1.0).read).merge('parent_id' => SecureRandom.uuid)
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

    it 'represents the interests of justice details' do
      expect(representation.fetch('interests_of_justice')).to eq submitted_application.fetch('interests_of_justice')
    end

    it 'represents the interests of justice passport details' do
      expect(representation.fetch('ioj_passport')).to eq submitted_application.fetch('ioj_passport')
    end

    it 'represents the means passport details' do
      expect(representation.fetch('means_passport')).to eq submitted_application.fetch('means_passport')
    end

    it 'represents the reference' do
      expect(representation.fetch('reference')).to eq submitted_application.fetch('reference')
    end

    it 'represents the id' do
      expect(representation.fetch('id')).to eq submitted_application.fetch('id')
    end
  end

  context 'when retrieved from the database' do
    it 'represents submitted_at' do
      expect(representation.fetch('submitted_at')).to eq submitted_at
    end

    it 'represents returned_at' do
      expect(representation.fetch('returned_at')).to eq returned_at
    end

    it 'represents the status' do
      expect(representation.fetch('status')).to eq status
    end

    it 'represents the return_details' do
      expect(representation.fetch('return_details').symbolize_keys).to eq return_details
    end
  end

  it 'represents the overall offence class within the case details' do
    expect(representation.fetch('case_details').fetch('offence_class')).to eq offence_class
  end
end
