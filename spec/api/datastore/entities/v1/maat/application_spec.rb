require 'rails_helper'

RSpec.describe Datastore::Entities::V1::MAAT::Application do
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
      return_details: { reason: nil, details: nil, returned_at: nil },
      offence_class: Types::OffenceClass['C'],
      work_stream: Types::WorkStreamType['criminal_applications_team'],
      submitted_application: submitted_application
    )
  end

  let(:submitted_application) do
    LaaCrimeSchemas.fixture(1.0) { |json| json.merge('parent_id' => SecureRandom.uuid) }
  end

  it 'represents the provider details' do
    expect(representation.fetch('provider_details')).to eq submitted_application.fetch('provider_details')
  end

  it 'represents the client details' do
    expect(representation.fetch('client_details')).to eq submitted_application.fetch('client_details')
  end

  describe 'ioj_bypass' do
    subject(:ioj_bypass) { representation.fetch('ioj_bypass') }

    it { is_expected.to be false }

    context 'when ioj are empty' do
      let(:submitted_application) { super().merge('interests_of_justice' => []) }

      it { is_expected.to be true }
    end

    context 'when ioj are blank' do
      let(:submitted_application) { super().merge('interests_of_justice' => nil) }

      it { is_expected.to be true }
    end
  end

  it 'represents the means passport details' do
    expect(representation.fetch('means_passport')).to eq submitted_application.fetch('means_passport')
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

  it 'represents submitted_at' do
    expect(representation.fetch('submitted_at')).to eq crime_application.submitted_at.iso8601(3)
  end

  it 'represents declaration_signed_at' do
    expect(representation.fetch('declaration_signed_at')).to eq crime_application.submitted_at.iso8601(3)
  end

  it 'represents date_stamp' do
    expect(representation.fetch('date_stamp')).to eq submitted_application.fetch('date_stamp')
  end

  describe 'case_details' do
    subject(:case_details) { representation.fetch('case_details') }

    it { is_expected.to be_a(Hash) }

    it 'includes the overall offence class within the case details' do
      expect(case_details.fetch('offence_class')).to eq('C')
    end
  end

  describe "conforms to the 'maat_application' schema" do
    let(:schema) do
      JSON.parse(File.read(File.join(
                             LaaCrimeSchemas.root, 'schemas', '1.0', 'maat_application.json'
                           )))
    end

    it 'exposes only the expected root properties' do
      expected_root_properties = schema['properties'].keys

      expect(representation.keys).to match_array(expected_root_properties)
    end

    it 'exposes only the expected case_details properties' do
      expected_case_details = schema.dig('properties', 'case_details', 'properties').keys

      expect(representation.fetch('case_details').keys).to match_array(expected_case_details)
    end
  end
end
