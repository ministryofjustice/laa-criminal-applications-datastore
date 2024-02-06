require 'rails_helper'

describe Redacting::Redact do
  subject { described_class.new(crime_application) }

  let(:crime_application) { CrimeApplication.new(submitted_application:) }
  let(:submitted_application) { JSON.parse(LaaCrimeSchemas.fixture(1.0).read) }

  let(:redacted_application) { crime_application.redacted_crime_application.submitted_application }

  # rubocop:disable Layout/FirstHashElementIndentation, RSpec/ExampleLength
  describe 'redacting of a submitted application' do
    before do
      subject.process!
    end

    context 'with provider details' do
      let(:provider_details) { redacted_application['provider_details'] }

      it 'redacts the expected attributes' do
        expect(provider_details).to eq({
          'office_code' => '1A123B',
          'provider_email' => 'provider@example.com',
          'legal_rep_first_name' => 'John',
          'legal_rep_last_name' => 'Doe',
          'legal_rep_telephone' => '__redacted__',
        })
      end
    end

    context 'with client details' do
      let(:client_details) { redacted_application['client_details'] }

      it 'redacts the expected attributes' do
        expect(client_details['applicant']).to eq({
          'first_name' => '__redacted__',
          'last_name' => '__redacted__',
          'other_names' => '',
          'nino' => '__redacted__',
          'date_of_birth' => '2001-06-09',
          'telephone_number' => '__redacted__',
          'correspondence_address_type' => 'home_address',
          'home_address' => {
            'lookup_id' => nil,
            'address_line_one' => '__redacted__',
            'address_line_two' => '__redacted__',
            'city' => 'Some nice city',
            'country' => 'United Kingdom',
            'postcode' => 'SW1A 2AA',
          },
          'benefit_type' => 'universal_credit',
          'correspondence_address' => nil
        })
      end
    end

    context 'with case details' do
      let(:case_details) { redacted_application['case_details'] }

      it 'redacts the expected attributes' do
        expect(case_details['codefendants']).to eq(
          [{
            'first_name' => '__redacted__',
            'last_name' => '__redacted__',
            'conflict_of_interest' => 'yes'
          }]
        )
      end
    end

    context 'with interests of justice' do
      let(:interests_of_justice) { redacted_application['interests_of_justice'] }

      it 'redacts the expected attributes' do
        expect(interests_of_justice).to eq(
          [{
            'type' => 'loss_of_liberty',
            'reason' => '__redacted__',
          }]
        )
      end
    end

    context 'with supporting evidence' do
      let(:supporting_evidence) { redacted_application['supporting_evidence'] }

      it 'redacts the expected attributes' do
        expect(supporting_evidence).to eq(
          [{
            's3_object_key' => '__redacted__',
            'filename' => '__redacted__',
            'file_size' => 12,
            'content_type' => 'application/pdf',
            'scan_at' => '2023-10-01 12:34:56',
          }]
        )
      end
    end

    context 'with additional information' do
      let(:submitted_application) do
        super().deep_merge('additional_information' => 'Additional information here')
      end

      let(:additional_information) { redacted_application['additional_information'] }

      it 'redacts the expected attributes' do
        expect(additional_information).to eq('__redacted__')
      end
    end
  end

  describe 'metadata attributes' do
    let(:metadata) { crime_application.redacted_crime_application.metadata }

    before do
      subject.process!
    end

    it 'contains the expected metadata json' do
      expect(metadata).to eq({
        'status' => 'submitted',
        'reviewed_at' => nil,
        'returned_at' => nil,
        'review_status' => 'application_received',
        'offence_class' => nil,
        'return_reason' => nil,
      })
    end
  end

  describe 'for blank or null attributes' do
    let(:submitted_application) do
      LaaCrimeSchemas.fixture(1.0) do |json|
        json.deep_merge(
          'client_details' => { 'applicant' => { 'other_names' => '', 'nino' => nil } }
        )
      end
    end

    it 'does not redact them, keep the original value' do
      subject.process!

      expect(redacted_application['client_details']['applicant']).to match(
        a_hash_including({
          'other_names' => '',
          'nino' => nil,
          'telephone_number' => '__redacted__',
        })
      )
    end
  end
  # rubocop:enable Layout/FirstHashElementIndentation, RSpec/ExampleLength

  describe 'invalid rules' do
    before do
      allow(Redacting::Rules).to receive(:pii_attributes).and_return(rules)
    end

    context 'when `redact` information is not found' do
      let(:rules) do
        { 'provider_details' => {} }
      end

      it 'raises a key not found error' do
        expect { subject.process! }.to raise_error(KeyError, /key not found: :redact/)
      end
    end

    context 'when the `type` is unrecognised' do
      let(:rules) do
        { 'provider_details' => { redact: %w[], type: :date } }
      end

      it 'raises a key not found error' do
        expect { subject.process! }.to raise_error(RuntimeError, /unknown rule path type: date/)
      end
    end
  end
end
