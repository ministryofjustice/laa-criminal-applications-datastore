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
    app_fixture = LaaCrimeSchemas.fixture(1.0) { |json| json.merge('parent_id' => SecureRandom.uuid) }
    means_details = JSON.parse(LaaCrimeSchemas.fixture(1.0, name: 'means').read)
    app_fixture.deep_merge('means_details' => means_details)
  end

  it 'represents the provider details' do
    expect(representation.fetch('provider_details')).to eq submitted_application.fetch('provider_details')
  end

  describe '#client_details' do
    subject(:client_details) { representation.fetch('client_details') }

    it 'represents the client details' do
      expect(client_details.keys).to eq %w[applicant partner]
    end

    describe '#applicant' do
      let(:applicant) do
        {
          benefit_type: 'universal_credit',
          correspondence_address: nil,
          correspondence_address_type: 'home_address',
          date_of_birth: '2001-06-09',
          first_name: 'Kit',
          has_partner: 'yes',
          home_address: {
            address_line_one: '1 Road',
            address_line_two: 'Village',
            city: 'Some nice city',
            country: 'United Kingdom',
            lookup_id: nil,
            postcode: 'SW1A 2AA'
          },
          last_jsa_appointment_date:  nil,
          last_name: 'Pound',
          nino: 'AJ123456C',
          other_names: '',
         residence_type: nil,
         telephone_number:  '07771231231'
        }.deep_stringify_keys
      end

      it 'represents the applicant' do
        expect(client_details.fetch('applicant')).to eq(applicant)
      end
    end

    describe '#partner' do
      let(:expected) do
        {
          benefit_type: nil,
          date_of_birth: '2001-12-23',
          first_name: 'Jennifer',
          last_jsa_appointment_date:  nil,
          last_name: 'Holland',
          nino: 'AB123456C',
          other_names: 'Diane',
          conflict_of_interest: 'no',
          involvement_in_case: 'codefendant',
        }.deep_stringify_keys
      end

      it 'represents the partner' do
        expect(client_details.fetch('partner')).to eq(expected)
      end
    end
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

  describe 'client_details' do
    subject(:client_details) { representation.fetch('client_details') }

    it { is_expected.to be_a(Hash) }

    context 'when benefit_type is not `none`' do
      it 'does not modify the benefit_type' do
        expect(client_details['applicant'].fetch('benefit_type')).to eq('universal_credit')
      end
    end

    context 'when benefit_type is `none`' do
      let(:submitted_application) do
        LaaCrimeSchemas.fixture(1.0) do |json|
          json.deep_merge(
            'client_details' => {
              'applicant' => { 'benefit_type' => 'none' }
            }
          )
        end
      end

      it 'sets benefit_type to nil' do
        expect(client_details['applicant'].fetch('benefit_type')).to be_nil
      end
    end
  end

  describe 'case_details' do
    subject(:case_details) { representation.fetch('case_details') }

    it { is_expected.to be_a(Hash) }

    it 'includes the overall offence class within the case details' do
      expect(case_details.fetch('offence_class')).to eq('C')
    end
  end

  describe 'MAAT validity' do
    let(:validator) { LaaCrimeSchemas::Validator.new(representation, version: 1.0, schema_name: 'maat_application') }

    it 'is valid' do
      expect(validator).to be_valid, -> { validator.fully_validate }
    end

    context 'when partner is not given' do
      let(:submitted_application) do
        LaaCrimeSchemas.fixture(1.0) do |json|
          json.deep_merge('client_details' => { 'partner' => nil })
        end
      end

      it 'is valid' do
        expect(validator).to be_valid, -> { validator.fully_validate }
      end
    end

    context 'when means details are not given' do
      let(:submitted_application) do
        LaaCrimeSchemas.fixture(1.0) do |json|
          json.deep_merge(
            'means_details' => {
              'income_details' => nil,
              'outgoings_details' => nil,
              'capital_details' => nil
            }
          )
        end
      end

      it 'is valid' do
        expect(validator).to be_valid, -> { validator.fully_validate }
      end
    end

    context 'when assets are missing' do
      let(:submitted_application) do
        LaaCrimeSchemas.fixture(1.0) do |json|
          json.merge(
            'means_details' => {
              'income_details' => nil,
              'outgoings_details' => nil,
              'capital_details' => { 'trust_fund_amount' => 1212 }
            }
          )
        end
      end

      it 'is valid' do
        expect(validator).to be_valid, -> { validator.fully_validate }
      end
    end

    context 'with attribute `manage_without_income` in `income_details`' do
      context 'when manage_without_income is valid' do
        let(:submitted_application) do
          LaaCrimeSchemas.fixture(1.0) do |json|
            json.merge(
              'means_details' => {
                'income_details' => {
                  'employment_type' => ['not_working'],
                  'manage_without_income' => 'living_on_streets'
                }
              }
            )
          end
        end

        it 'is valid' do
          expect(validator).to be_valid, -> { validator.fully_validate }
        end
      end

      context 'when manage_without_income is invalid' do
        let(:submitted_application) do
          LaaCrimeSchemas.fixture(1.0) do |json|
            json.merge(
              'means_details' => {
                'income_details' => {
                  'employment_type' => ['not_working'],
                  'manage_without_income' => 'invalid_text'
                }
              }
            )
          end
        end

        it 'is valid' do
          expect(validator).not_to be_valid, -> { validator.fully_validate }
        end
      end

      context 'when manage_without_income is nil' do
        let(:submitted_application) do
          LaaCrimeSchemas.fixture(1.0) do |json|
            json.merge(
              'means_details' => {
                'income_details' => {
                  'employment_type' => ['not_working'],
                  'manage_without_income' => nil
                }
              }
            )
          end
        end

        it 'is valid' do
          expect(validator).to be_valid, -> { validator.fully_validate }
        end
      end

      context 'when manage_without_income is missing' do
        let(:submitted_application) do
          LaaCrimeSchemas.fixture(1.0) do |json|
            json.merge(
              'means_details' => {
                'income_details' => {
                  'employment_type' => ['not_working']
                }
              }
            )
          end
        end

        it 'is valid' do
          expect(validator).to be_valid, -> { validator.fully_validate }
        end
      end
    end

    context 'with `partner_trust_fund_amount` in `capital_details`' do
      context 'when partner_trust_fund_amount is present' do
        let(:submitted_application) do
          LaaCrimeSchemas.fixture(1.0) do |json|
            json.merge(
              'means_details' => {
                'income_details' => nil,
                'outgoings_details' => nil,
                'capital_details' => { 'partner_trust_fund_amount_held' => partner_trust_fund_amount_held }
              }
            )
          end
        end

        context 'when valid' do
          let(:partner_trust_fund_amount_held) { 1000 }

          it 'is valid' do
            expect(validator).to be_valid, -> { validator.fully_validate }
          end
        end

        context 'when invalid' do
          let(:partner_trust_fund_amount_held) { 'should_be_a_number' }

          it 'is valid' do
            expect(validator).not_to be_valid, -> { validator.fully_validate }
          end
        end
      end

      context 'when partner_trust_fund_amount is not present' do
        let(:partner_trust_fund_amount_held) { nil }

        it 'is valid' do
          expect(validator).to be_valid, -> { validator.fully_validate }
        end
      end
    end

    # rubocop:disable RSpec/ExampleLength
    context 'when `income_payments`' do
      context 'when income_payment of type `other` is present' do
        let(:submitted_application) do
          LaaCrimeSchemas.fixture(1.0) do |json|
            json.merge(
              'means_details' => {
                'income_details' => {
                  'employment_type' => ['not_working'],
                  'income_payments' => [
                    {
                      'payment_type' => 'employment',
                      'amount' => 10_000,
                      'frequency' => 'week',
                      'ownership_type' => 'applicant',
                      'metadata' => {}
                    },
                    {
                      'payment_type' => 'state_pension',
                      'amount' => 10_000,
                      'frequency' => 'week',
                      'ownership_type' => 'applicant',
                      'metadata' => {}
                    },
                    {
                      'payment_type' => 'maintenance',
                      'amount' => 30_000,
                      'frequency' => 'month',
                      'ownership_type' => 'applicant',
                      'metadata' => {}
                    },
                    {
                      'payment_type' => 'student_loan_grant',
                      'amount' => 50_000,
                      'frequency' => 'month',
                      'ownership_type' => 'applicant',
                      'metadata' => {}
                    },
                    {
                      'payment_type' => 'maintenance',
                      'amount' => 15_000,
                      'frequency' => 'month',
                      'ownership_type' => 'partner',
                      'metadata' => {}
                    },
                    {
                      'payment_type' => 'student_loan_grant',
                      'amount' => 25_000,
                      'frequency' => 'annual',
                      'ownership_type' => 'partner',
                      'metadata' => {}
                    },
                    {
                      'payment_type' => 'other',
                      'amount' => 10_000,
                      'frequency' => 'month',
                      'ownership_type' => 'partner',
                      'metadata' => {
                        'details' => 'Details of the other partner payment'
                      }
                    },
                    {
                      'payment_type' => 'other',
                      'amount' => 250,
                      'frequency' => 'month',
                      'ownership_type' => 'applicant',
                      'metadata' => {
                        'details' => 'Details of the other payment'
                      }
                    }
                  ]
                }
              }
            )
          end
        end

        it 'is valid' do
          expect(validator).to be_valid, -> { validator.fully_validate }
        end

        it 'add `student_loan_grant` amount to `other` payment amount' do
          income_payments = representation.dig('means_details', 'income_details', 'income_payments')
          expect(income_payments).to contain_exactly(
            {
              'payment_type' => 'state_pension',
                'amount' => 10_000,
                'frequency' => 'week',
                'ownership_type' => 'applicant',
                'metadata' => {}
            },
            {
              'payment_type' => 'maintenance',
                'amount' => 30_000,
                'frequency' => 'month',
                'ownership_type' => 'applicant',
                'metadata' => {}
            },
            {
              'payment_type' => 'student_loan_grant',
                'amount' => 50_000,
                'frequency' => 'month',
                'ownership_type' => 'applicant',
                'metadata' => {}
            },
            {
              'payment_type' => 'maintenance',
              'amount' => 15_000,
              'frequency' => 'month',
              'ownership_type' => 'partner',
              'metadata' => {}
            },
            {
              'payment_type' => 'student_loan_grant',
              'amount' => 25_000,
              'frequency' => 'annual',
              'ownership_type' => 'partner',
              'metadata' => {}
            },
            {
              'payment_type' => 'other',
              'amount' => 145_000, # other:(10_000 * 12) + student_loan_grant:(25_000)
              'frequency' => 'annual',
              'ownership_type' => 'partner',
              'metadata' => {
                'details' => 'Details of the other partner payment'
              },
              'details' => 'Details of the other partner payment'
            },
            {
              'payment_type' => 'other',
                'amount' => 603_000, # other:(250 * 12) + student_loan_grant:(50_000 * 12)
                'frequency' => 'annual',
                'ownership_type' => 'applicant',
                'metadata' => {
                  'details' => 'Details of the other payment'
                },
                'details' => 'Details of the other payment'
            }
          )
        end
      end

      context 'when income_payment of type `other` is missing' do
        let(:submitted_application) do
          LaaCrimeSchemas.fixture(1.0) do |json|
            json.merge(
              'means_details' => {
                'income_details' => {
                  'employment_type' => ['not_working'],
                  'income_payments' => [
                    {
                      'payment_type' => 'employment',
                      'amount' => 10_000,
                      'frequency' => 'week',
                      'ownership_type' => 'applicant',
                      'metadata' => {}
                    },
                    {
                      'payment_type' => 'state_pension',
                      'amount' => 10_000,
                      'frequency' => 'week',
                      'ownership_type' => 'applicant',
                      'metadata' => {}
                    },
                    {
                      'payment_type' => 'maintenance',
                      'amount' => 30_000,
                      'frequency' => 'month',
                      'ownership_type' => 'applicant',
                      'metadata' => {}
                    },
                    {
                      'payment_type' => 'rent',
                      'amount' => 600,
                      'frequency' => 'week',
                      'ownership_type' => 'applicant',
                      'metadata' => {}
                    },
                    {
                      'payment_type' => 'student_loan_grant',
                      'amount' => 50_000,
                      'frequency' => 'month',
                      'ownership_type' => 'applicant',
                      'metadata' => {}
                    },
                    {
                      'payment_type' => 'maintenance',
                      'amount' => 15_000,
                      'frequency' => 'month',
                      'ownership_type' => 'partner',
                      'metadata' => {}
                    },
                    {
                      'payment_type' => 'student_loan_grant',
                      'amount' => 25_000,
                      'frequency' => 'annual',
                      'ownership_type' => 'partner',
                      'metadata' => {}
                    },
                  ]
                }
              }
            )
          end
        end

        it 'is valid' do
          expect(validator).to be_valid, -> { validator.fully_validate }
        end

        it 'add `student_loan_grant` amount to `other` payment amount' do
          income_payments = representation.dig('means_details', 'income_details', 'income_payments')
          expect(income_payments).to contain_exactly(
            {
              'payment_type' => 'state_pension',
                'amount' => 10_000,
                'frequency' => 'week',
                'ownership_type' => 'applicant',
                'metadata' => {}
            },
            {
              'payment_type' => 'maintenance',
                'amount' => 30_000,
                'frequency' => 'month',
                'ownership_type' => 'applicant',
                'metadata' => {}
            },
            {
              'payment_type' => 'rent',
                'amount' => 600,
                'frequency' => 'week',
                'ownership_type' => 'applicant',
                'metadata' => {}
            },
            {
              'payment_type' => 'student_loan_grant',
                'amount' => 50_000,
                'frequency' => 'month',
                'ownership_type' => 'applicant',
                'metadata' => {}
            },
            {
              'payment_type' => 'maintenance',
              'amount' => 15_000,
              'frequency' => 'month',
              'ownership_type' => 'partner',
              'metadata' => {}
            },
            {
              'payment_type' => 'student_loan_grant',
              'amount' => 25_000,
              'frequency' => 'annual',
              'ownership_type' => 'partner',
              'metadata' => {}
            },
            {
              'payment_type' => 'other',
                'amount' => 631_200, # rent:(600 * 52) + student_loan_grant:(50000 * 12)
                'frequency' => 'annual',
                'ownership_type' => 'applicant',
                'metadata' => {
                  'details' => 'Details of the other applicant payment'
                },
                'details' => 'Details of the other applicant payment'
            },
            {
              'payment_type' => 'other',
              'amount' => 25_000, # student_loan_grant:(25_000)
              'frequency' => 'annual',
              'ownership_type' => 'partner',
              'metadata' => {
                'details' => 'Details of the other partner payment'
              },
              'details' => 'Details of the other partner payment'
            },
          )
        end
      end
    end
    # rubocop:enable RSpec/ExampleLength
  end

  describe "conforms to the 'maat_application' schema" do
    let(:schema) do
      schema_file_path = File.join(LaaCrimeSchemas.root, 'schemas', '1.0', 'maat_application.json')
      JSON.parse(File.read(schema_file_path))
    end

    let(:maat_means_schema) do
      schema_file_path = File.join(LaaCrimeSchemas.root, 'schemas', '1.0', 'maat', 'means.json')
      JSON.parse(File.read(schema_file_path))
    end

    it 'exposes only the expected case_details root properties' do
      expected_case_details = schema.dig('properties', 'case_details', 'properties').keys

      expect(representation.fetch('case_details').keys).to match_array(expected_case_details)
    end

    it 'exposes only the expected client_details root properties' do
      expected_case_details = schema.dig('properties', 'client_details', 'properties').keys

      expect(representation.fetch('client_details').keys).to match_array(expected_case_details)
    end

    it 'exposes only the expected applicant root properties' do
      expected_applicant_details = schema.dig(
        'properties', 'client_details', 'properties', 'applicant', 'properties'
      ).keys

      expect(representation.dig('client_details', 'applicant').keys).to match_array(expected_applicant_details)
    end

    describe 'means details relevant to MAAT' do
      it 'exposes only the expected means details root properties' do
        expected_means_details = maat_means_schema['properties'].keys

        expect(representation['means_details'].keys).to match_array(expected_means_details)
      end

      it 'exposes only the expected income_details properties for application fixture' do
        possible_income_details = maat_means_schema.dig('properties', 'income_details', 'properties').keys

        fixture_properties = representation['means_details']['income_details'].keys

        expect(possible_income_details).to include(*fixture_properties)
      end

      it 'exposes only the expected capital_details properties for application fixture' do
        possible_capital_details = maat_means_schema.dig('properties', 'capital_details', 'properties').keys

        fixture_properties = representation['means_details']['capital_details'].keys

        expect(possible_capital_details).to include(*fixture_properties)
      end

      it 'exposes only the expected outgoings_details properties for application fixture' do
        possible_outgoings_details = maat_means_schema.dig('properties', 'outgoings_details', 'properties').keys

        fixture_properties = representation['means_details']['outgoings_details'].keys

        expect(possible_outgoings_details).to include(*fixture_properties)
      end
    end

    describe 'extract_details' do
      it 'exposes details not metadata for income_benefits' do
        expected_income_benefits = maat_means_schema.dig(
          'properties', 'income_details', 'properties', 'income_benefits', 'items', 'properties'
        ).keys

        income_benefits = representation.dig('means_details', 'income_details', 'income_benefits')
        other_income_benefit = income_benefits.find { |income_benefit| income_benefit['payment_type'] == 'other' }

        expect(other_income_benefit.keys).to match_array(expected_income_benefits)
        expect(other_income_benefit.keys).to include('details')
      end
    end
  end
end
