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

    context 'when correspondence_address_type is not given' do
      let(:submitted_application) do
        LaaCrimeSchemas.fixture(1.0) do |json|
          json.deep_merge('client_details' => { 'applicant' => { 'correspondence_address_type' => nil } })
        end
      end

      it 'is valid' do
        expect(validator).to be_valid, -> { validator.fully_validate }
      end
    end

    context 'when case_details hearing_date is not given' do
      let(:submitted_application) do
        LaaCrimeSchemas.fixture(1.0) do |json|
          json.deep_merge('case_details' => { 'hearing_date' => nil })
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
    context 'with `income_payments`' do
      context 'when `income_payments` are missing' do
        let(:submitted_application) do
          LaaCrimeSchemas.fixture(1.0) do |json|
            json.merge(
              'means_details' => {
                'income_details' => {
                  'employment_type' => ['not_working'],
                  'income_payments' => []
                }
              }
            )
          end
        end

        it 'is valid' do
          expect(validator).to be_valid, -> { validator.fully_validate }
        end

        it 'returns empty income_payments' do
          income_payments = representation.dig('means_details', 'income_details', 'income_payments')
          expect(income_payments).to be_empty
        end
      end

      context 'when `income_payments` are present' do
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

          it 'adds `student_loan_grant` amount to `other` payment amount' do
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
                'payment_type' => 'maintenance',
                'amount' => 15_000,
                'frequency' => 'month',
                'ownership_type' => 'partner',
                'metadata' => {}
              },
              {
                'payment_type' => 'other',
                'amount' => 145_000, # other(10_000 * 12) + student_loan_grant(25_000)
                'frequency' => 'annual',
                'ownership_type' => 'partner',
                'metadata' => {
                  'details' => <<~HEREDOC
                    Details of the other partner payment
                    Partner: Student loan grant:£250.00/annual, Other:£100.00/month
                  HEREDOC
                },
                'details' => <<~HEREDOC
                  Details of the other partner payment
                  Partner: Student loan grant:£250.00/annual, Other:£100.00/month
                HEREDOC
              },
              {
                'payment_type' => 'other',
                  'amount' => 603_000, # other(250 * 12) + student_loan_grant(50_000 * 12)
                  'frequency' => 'annual',
                  'ownership_type' => 'applicant',
                  'metadata' => {
                    'details' => <<~HEREDOC
                      Details of the other payment
                      Applicant: Student loan grant:£500.00/month, Other:£2.50/month
                    HEREDOC
                  },
                  'details' => <<~HEREDOC
                    Details of the other payment
                    Applicant: Student loan grant:£500.00/month, Other:£2.50/month
                  HEREDOC

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

          it 'creates `other` income payment add `student_loan_grant` amount to `other` income payment amount' do
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
                'payment_type' => 'maintenance',
                'amount' => 15_000,
                'frequency' => 'month',
                'ownership_type' => 'partner',
                'metadata' => {}
              },
              {
                'payment_type' => 'other',
                  'amount' => 631_200, # rent(600 * 52) + student_loan_grant(50000 * 12)
                  'frequency' => 'annual',
                  'ownership_type' => 'applicant',
                  'metadata' => {
                    'details' => 'Applicant: Rent:£6.00/week, Student loan grant:£500.00/month'
                  },
                  'details' => 'Applicant: Rent:£6.00/week, Student loan grant:£500.00/month'
              },
              {
                'payment_type' => 'other',
                'amount' => 25_000, # student_loan_grant(25_000)
                'frequency' => 'annual',
                'ownership_type' => 'partner',
                'metadata' => {
                  'details' => 'Partner: Student loan grant:£250.00/annual'
                },
                'details' => 'Partner: Student loan grant:£250.00/annual'
              },
            )
          end
        end

        context 'when other income_payments are missing' do
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
                        'payment_type' => 'maintenance',
                        'amount' => 15_000,
                        'frequency' => 'month',
                        'ownership_type' => 'partner',
                        'metadata' => {}
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

          it 'adds `student_loan_grant` amount to `other` payment amount' do
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
                'payment_type' => 'maintenance',
                'amount' => 15_000,
                'frequency' => 'month',
                'ownership_type' => 'partner',
                'metadata' => {}
              }
            )
          end
        end
      end
    end

    context 'with `income_benefits`' do
      context 'when `income_benefits` are missing' do
        let(:submitted_application) do
          LaaCrimeSchemas.fixture(1.0) do |json|
            json.merge(
              'means_details' => {
                'income_details' => {
                  'employment_type' => ['not_working'],
                  'income_benefits' => []
                }
              }
            )
          end
        end

        it 'is valid' do
          expect(validator).to be_valid, -> { validator.fully_validate }
        end

        it 'returns empty income_benefits' do
          income_benefits = representation.dig('means_details', 'income_details', 'income_benefits')
          expect(income_benefits).to be_empty
        end
      end

      context 'when `income_benefits` are present' do
        context 'when income_benefit of type `other` is present' do
          let(:submitted_application) do
            LaaCrimeSchemas.fixture(1.0) do |json|
              json.merge(
                'means_details' => {
                  'income_details' => {
                    'employment_type' => ['not_working'],
                    'income_benefits' => [
                      {
                        'payment_type' => 'child',
                        'amount' => 500,
                        'frequency' => 'week',
                        'ownership_type' => 'applicant',
                        'metadata' => {}
                      },
                      {
                        'payment_type' => 'incapacity',
                        'amount' => 1000,
                        'frequency' => 'month',
                        'ownership_type' => 'applicant',
                        'metadata' => {}
                      },
                      {
                        'payment_type' => 'jsa',
                        'amount' => 700,
                        'frequency' => 'month',
                        'ownership_type' => 'applicant',
                        'metadata' => {}
                      },
                      {
                        'payment_type' => 'industrial_injuries_disablement',
                        'amount' => 1500,
                        'frequency' => 'month',
                        'ownership_type' => 'partner',
                        'metadata' => {}
                      },
                      {
                        'payment_type' => 'jsa',
                        'amount' => 1500,
                        'frequency' => 'annual',
                        'ownership_type' => 'partner',
                        'metadata' => {}
                      },
                      {
                        'payment_type' => 'other',
                        'amount' => 550,
                        'frequency' => 'month',
                        'ownership_type' => 'partner',
                        'metadata' => {
                          'details' => 'Details of the other partner benefit'
                        }
                      },
                      {
                        'payment_type' => 'other',
                        'amount' => 750,
                        'frequency' => 'month',
                        'ownership_type' => 'applicant',
                        'metadata' => {
                          'details' => 'Details of the other benefit'
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

          it 'adds `jsa` amount to `other` benefit amount' do
            income_benefits = representation.dig('means_details', 'income_details', 'income_benefits')
            expect(income_benefits).to contain_exactly(
              {
                'payment_type' => 'child',
                'amount' => 500,
                'frequency' => 'week',
                'ownership_type' => 'applicant',
                'metadata' => {}
              },
              {
                'payment_type' => 'incapacity',
                'amount' => 1000,
                'frequency' => 'month',
                'ownership_type' => 'applicant',
                'metadata' => {}
              },
              {
                'payment_type' => 'industrial_injuries_disablement',
                'amount' => 1500,
                'frequency' => 'month',
                'ownership_type' => 'partner',
                'metadata' => {}
              },
              {
                'payment_type' => 'other',
                'amount' => 8100, # other(550 * 12) + jsa(1500)
                'frequency' => 'annual',
                'ownership_type' => 'partner',
                'metadata' => {
                  'details' => <<~HEREDOC
                    Details of the other partner benefit
                    Partner: Jsa:£15.00/annual, Other:£5.50/month
                  HEREDOC
                },
                'details' => <<~HEREDOC
                  Details of the other partner benefit
                  Partner: Jsa:£15.00/annual, Other:£5.50/month
                HEREDOC
              },
              {
                'payment_type' => 'other',
                'amount' => 17_400, # other(750 * 12) + jsa(700 * 12)
                'frequency' => 'annual',
                'ownership_type' => 'applicant',
                'metadata' => {
                  'details' => <<~HEREDOC
                    Details of the other benefit
                    Applicant: Jsa:£7.00/month, Other:£7.50/month
                  HEREDOC
                },
                'details' => <<~HEREDOC
                  Details of the other benefit
                  Applicant: Jsa:£7.00/month, Other:£7.50/month
                HEREDOC
              }
            )
          end
        end

        context 'when income_benefit of type `other` is missing' do
          let(:submitted_application) do
            LaaCrimeSchemas.fixture(1.0) do |json|
              json.merge(
                'means_details' => {
                  'income_details' => {
                    'employment_type' => ['not_working'],
                    'income_benefits' => [
                      {
                        'payment_type' => 'child',
                        'amount' => 500,
                        'frequency' => 'week',
                        'ownership_type' => 'applicant',
                        'metadata' => {}
                      },
                      {
                        'payment_type' => 'incapacity',
                        'amount' => 1000,
                        'frequency' => 'month',
                        'ownership_type' => 'applicant',
                        'metadata' => {}
                      },
                      {
                        'payment_type' => 'jsa',
                        'amount' => 700,
                        'frequency' => 'month',
                        'ownership_type' => 'applicant',
                        'metadata' => {}
                      },
                      {
                        'payment_type' => 'industrial_injuries_disablement',
                        'amount' => 1500,
                        'frequency' => 'month',
                        'ownership_type' => 'partner',
                        'metadata' => {}
                      },
                      {
                        'payment_type' => 'jsa',
                        'amount' => 1500,
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

          it 'creates `other` income benefit and add `jsa` amount to `other` income benefit amount' do
            income_benefits = representation.dig('means_details', 'income_details', 'income_benefits')
            expect(income_benefits).to contain_exactly(
              {
                'payment_type' => 'child',
                'amount' => 500,
                'frequency' => 'week',
                'ownership_type' => 'applicant',
                'metadata' => {}
              },
              {
                'payment_type' => 'incapacity',
                'amount' => 1000,
                'frequency' => 'month',
                'ownership_type' => 'applicant',
                'metadata' => {}
              },
              {
                'payment_type' => 'industrial_injuries_disablement',
                'amount' => 1500,
                'frequency' => 'month',
                'ownership_type' => 'partner',
                'metadata' => {}
              },
              {
                'payment_type' => 'other',
                'amount' => 8400, # jsa(700 * 12)
                'frequency' => 'annual',
                'ownership_type' => 'applicant',
                'metadata' => {
                  'details' => 'Applicant: Jsa:£7.00/month'
                },
                'details' => 'Applicant: Jsa:£7.00/month'
              },
              {
                'payment_type' => 'other',
                'amount' => 1500, # jsa(1500)
                'frequency' => 'annual',
                'ownership_type' => 'partner',
                'metadata' => {
                  'details' => 'Partner: Jsa:£15.00/annual'
                },
                'details' => 'Partner: Jsa:£15.00/annual'
              }
            )
          end
        end

        context 'when other income_benefits are missing' do
          let(:submitted_application) do
            LaaCrimeSchemas.fixture(1.0) do |json|
              json.merge(
                'means_details' => {
                  'income_details' => {
                    'employment_type' => ['not_working'],
                    'income_benefits' => [
                      {
                        'payment_type' => 'child',
                        'amount' => 500,
                        'frequency' => 'week',
                        'ownership_type' => 'applicant',
                        'metadata' => {}
                      },
                      {
                        'payment_type' => 'incapacity',
                        'amount' => 1000,
                        'frequency' => 'month',
                        'ownership_type' => 'applicant',
                        'metadata' => {}
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

          it 'creates `other` income benefit and add `jsa` amount to `other` income benefit amount' do
            income_benefits = representation.dig('means_details', 'income_details', 'income_benefits')
            expect(income_benefits).to contain_exactly(
              {
                'payment_type' => 'child',
                'amount' => 500,
                'frequency' => 'week',
                'ownership_type' => 'applicant',
                'metadata' => {}
              },
              {
                'payment_type' => 'incapacity',
                'amount' => 1000,
                'frequency' => 'month',
                'ownership_type' => 'applicant',
                'metadata' => {}
              }
            )
          end
        end
      end
    end

    context 'with `income_payments` and `income_benefits`' do
      context 'when `income_payments` and `income_benefits` are missing' do
        let(:submitted_application) do
          LaaCrimeSchemas.fixture(1.0) do |json|
            json.merge(
              'means_details' => {
                'income_details' => {
                  'employment_type' => ['not_working'],
                  'income_payments' => [],
                  'income_benefits' => []
                }
              }
            )
          end
        end

        it 'is valid' do
          expect(validator).to be_valid, -> { validator.fully_validate }
        end

        it 'returns empty income_payments' do
          income_payments = representation.dig('means_details', 'income_details', 'income_payments')
          expect(income_payments).to be_empty
        end

        it 'returns empty income_benefits' do
          income_benefits = representation.dig('means_details', 'income_details', 'income_benefits')
          expect(income_benefits).to be_empty
        end
      end

      context 'when `income_payments` and `income_benefits` are present' do
        let(:submitted_application) do
          LaaCrimeSchemas.fixture(1.0) do |json|
            json.merge(
              'means_details' => {
                'income_details' => {
                  'employment_type' => ['not_working'],
                  'income_payments' => [
                    {
                      'amount' => 100_000,
                      'metadata' => {},
                      'frequency' => 'annual',
                      'payment_type' => 'state_pension',
                      'ownership_type' => 'applicant'
                    },
                    {
                      'amount' => 10_000,
                      'metadata' => {},
                      'frequency' => 'fortnight',
                      'payment_type' => 'student_loan_grant',
                      'ownership_type' => 'applicant'
                    },
                    {
                      'amount' => 10_000,
                      'metadata' => {},
                      'frequency' => 'four_weeks',
                      'payment_type' => 'board_from_family',
                      'ownership_type' => 'applicant'
                    },
                    {
                      'amount' => 5000,
                      'metadata' =>
                       {
                         'details' => 'Details of the other applicant payment'
                       },
                     'frequency' => 'week',
                     'payment_type' => 'other',
                     'ownership_type' => 'applicant'
                    },
                    {
                      'amount' => 40_000,
                      'metadata' => {},
                      'frequency' => 'fortnight',
                      'payment_type' => 'state_pension',
                      'ownership_type' => 'partner'
                    },
                    {
                      'amount' => 10_000,
                      'metadata' => {},
                      'frequency' => 'week',
                      'payment_type' => 'interest_investment',
                      'ownership_type' => 'partner'
                    },
                    {
                      'amount' => 6000,
                      'metadata' => {},
                      'frequency' => 'week',
                      'payment_type' => 'from_friends_relatives',
                      'ownership_type' => 'partner'
                    }
                  ],
                  'income_benefits' => [
                    {
                      'amount' => 50_000,
                      'metadata' => {},
                      'frequency' => 'fortnight',
                      'payment_type' => 'jsa',
                      'ownership_type' => 'applicant'
                    },
                    {
                      'amount' => 70_000,
                      'metadata' => {
                        'details' => 'Details of the other income benefit'
                      },
                     'frequency' => 'month',
                     'payment_type' => 'other',
                     'ownership_type' => 'applicant'
                    },
                    {
                      'amount' => 5000,
                      'metadata' => {},
                      'frequency' => 'fortnight',
                      'payment_type' => 'child',
                      'ownership_type' => 'partner'
                    },
                    {
                      'amount' => 80_000,
                      'metadata' => {
                        'details' => 'Details of the other income benefit'
                      },
                     'frequency' => 'month',
                     'payment_type' => 'other',
                     'ownership_type' => 'partner'
                    }
                  ],
                  'dividends' => {
                    'trust_fund_yearly_dividend' => 12_550,
                    'partner_trust_fund_yearly_dividend' => 10_000
                  },
                }
              },
            )
          end
        end

        it 'is valid' do
          expect(validator).to be_valid, -> { validator.fully_validate }
        end

        it 'return updated income_payments' do
          income_payments = representation.dig('means_details', 'income_details', 'income_payments')

          expect(income_payments).to contain_exactly(
            {
              'amount' => 100_000,
              'metadata' => {},
              'frequency' => 'annual',
              'payment_type' => 'state_pension',
              'ownership_type' => 'applicant'
            },
            {
              'amount' => 662_550,
              'metadata' =>
                {
                  'details' => <<~HEREDOC
                    Details of the other applicant payment
                    Applicant: Student loan grant:£100.00/fortnight, Board from family:£100.00/four_weeks, Other:£50.00/week, Trust fund dividend:£125.50/annual
                  HEREDOC
                },
              'frequency' => 'annual',
              'payment_type' => 'other',
              'ownership_type' => 'applicant',
              'details' => <<~HEREDOC
                Details of the other applicant payment
                Applicant: Student loan grant:£100.00/fortnight, Board from family:£100.00/four_weeks, Other:£50.00/week, Trust fund dividend:£125.50/annual
              HEREDOC
            },
            {
              'amount' => 40_000,
              'metadata' => {},
              'frequency' => 'fortnight',
              'payment_type' => 'state_pension',
              'ownership_type' => 'partner'
            },
            {
              'amount' => 10_000,
              'metadata' => {},
              'frequency' => 'week',
              'payment_type' => 'interest_investment',
              'ownership_type' => 'partner'
            },
            {
              'amount' => 322_000,
              'metadata' => {
                'details' => 'Partner: From friends relatives:£60.00/week, Trust fund dividend:£100.00/annual'
              },
              'frequency' => 'annual',
              'payment_type' => 'other',
              'ownership_type' => 'partner',
              'details' => 'Partner: From friends relatives:£60.00/week, Trust fund dividend:£100.00/annual'
            }
          )
        end

        it 'return updated income_benefits' do
          income_benefits = representation.dig('means_details', 'income_details', 'income_benefits')

          expect(income_benefits).to contain_exactly(
            {
              'amount' => 2_140_000,
              'metadata' =>
                {
                  'details' =>  <<~HEREDOC
                    Details of the other income benefit
                    Applicant: Jsa:£500.00/fortnight, Other:£700.00/month
                  HEREDOC
                },
              'frequency' => 'annual',
              'payment_type' => 'other',
              'ownership_type' => 'applicant',
              'details' => <<~HEREDOC
                Details of the other income benefit
                Applicant: Jsa:£500.00/fortnight, Other:£700.00/month
              HEREDOC
            },
            {
              'amount' => 5000,
              'metadata' => {},
              'frequency' => 'fortnight',
              'payment_type' => 'child',
              'ownership_type' => 'partner'
            },
            {
              'amount' => 960_000,
              'metadata' =>
                {
                  'details' => <<~HEREDOC
                    Details of the other income benefit
                    Partner: Other:£800.00/month
                  HEREDOC
                },
              'frequency' => 'annual',
              'payment_type' => 'other',
              'ownership_type' => 'partner',
              'details' => <<~HEREDOC
                Details of the other income benefit
                Partner: Other:£800.00/month
              HEREDOC
            }
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

  # rubocop:disable Layout/LineLength
  describe '#chop!' do
    context 'with excessive provider details' do
      let(:submitted_application) do
        LaaCrimeSchemas.fixture(1.0) do |json|
          json.deep_merge(
            'provider_details' => {
              'office_code' => '1A123BXYZ123',
              'provider_email' => 'provider@example.com' * 15,
              'legal_rep_last_name' => 'This-Person-Has-A-Tripled-Barrelled Surname',
              'legal_rep_telephone' => '08828882990',
              'legal_rep_first_name' => 'Michael Angelo',
            }
          )
        end
      end

      let(:provider_details) { representation['provider_details'] }

      it 'truncates legal rep name to initial and last name' do
        expect(provider_details['legal_rep_first_name']).to eq 'M'
        expect(provider_details['legal_rep_last_name']).to eq 'This-Person-Has-A-Tripled-Barrelled...'
      end

      it 'truncates legal rep email address and office code' do
        expect(provider_details['office_code']).to eq '1A1...' # TODO: Not sure if office code should have ...
        expect(provider_details['provider_email']).to eq 'provider@example.comprovider@example.comprovider@example.comprovider@example.comprovider@example.comprovider@example.comprovider@example.comprovider@example.comprovider@example.comprovider@example.comprovider@example.comprovider@example.comprovider@exa...'
      end
    end

    context 'with excessive applicant and partner details' do
      let(:submitted_application) do
        LaaCrimeSchemas.fixture(1.0) do |json|
          json.deep_merge(
            'client_details' => {
              'applicant' => {
                'first_name' => 'First Name' * 5,
                'last_name' => 'Last Name' * 5,
                'other_names' => 'Other Names' * 5,
                'telephone_number' => '123456789012345678901234',
                'nino' => 'NC123457ANC123457ANC123457A',
                'home_address' => {
                  'lookup_id' => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
                  'address_line_one' => '89 Derby Road' * 10,
                  'address_line_two' => 'Trenttown' * 20,
                  'city' => 'Nottingham' * 15,
                  'postcode' => 'NG1 7HD XXXXX',
                },
                'correspondence_address' => {
                  'lookup_id' => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
                  'address_line_one' => '11 Manchester Road' * 10,
                  'address_line_two' => 'Merseytown' * 20,
                  'city' => 'Liverpool' * 15,
                  'postcode' => 'L31 7HD XXXXX',
                },
              },
              'partner' => {
                'first_name' => 'Partner Name' * 5,
                'last_name' => 'Partner Last Name' * 5,
                'other_names' => 'Partner Other Names' * 5,
                'nino' => 'NC123457ANC123457ANC123457A',
              },
            }
          )
        end
      end

      it 'truncates applicant details', :aggregate_failures do
        applicant = representation.dig('client_details', 'applicant')
        details = applicant.slice('first_name', 'last_name', 'other_names', 'telephone_number', 'nino')

        expect(details).to eq(
          {
            'first_name' => 'First NameFirst NameFirst NameFirst N...',
            'last_name' => 'Last NameLast NameLast NameLast NameL...',
            'other_names' => 'Other NamesOther NamesOther NamesOthe...',
            'telephone_number' => '12345678901234567...',
            'nino' => 'NC12345...',
          }
        )

        expect(details.values.map(&:length)).to eq [40, 40, 40, 20, 10]
      end

      it 'truncates partner details' do
        partner = representation.dig('client_details', 'partner')
        details = partner.slice('first_name', 'last_name', 'other_names', 'nino')

        expect(details).to eq(
          {
            'first_name' => 'Partner NamePartner NamePartner NameP...',
            'last_name' => 'Partner Last NamePartner Last NamePar...',
            'other_names' => 'Partner Other NamesPartner Other Name...',
            'nino' => 'NC12345...',
          }
        )

        expect(details.values.map(&:length)).to eq [40, 40, 40, 10]
      end

      it 'truncates home addresses' do
        home_address = representation.dig('client_details', 'applicant', 'home_address')
        details = home_address.slice('lookup_id', 'address_line_one', 'address_line_two', 'city', 'postcode')

        expect(details).to eq(
          {
            'lookup_id' => 'ABCDEFG...',
            'address_line_one' => '89 Derby Road89 Derby Road89 Derby Road89 Derby Road89 Derby Road89 Derby Road89 Derby Road89 Der...',
            'address_line_two' => 'TrenttownTrenttownTrenttownTrenttownTrenttownTrenttownTrenttownTrenttownTrenttownTrenttownTrentto...',
            'city' => 'NottinghamNottinghamNottinghamNottinghamNottinghamNottinghamNottinghamNottinghamNottinghamNotting...',
            'postcode' => 'NG1 7HD...',
          }
        )

        expect(details.values.map(&:length)).to eq [10, 100, 100, 100, 10]
      end

      it 'truncates correspondence address' do
        correspondence_address = representation.dig('client_details', 'applicant', 'correspondence_address')
        details = correspondence_address.slice('lookup_id', 'address_line_one', 'address_line_two', 'city', 'postcode')

        expect(details).to eq(
          {
            'lookup_id' => 'ABCDEFG...',
            'address_line_one' => '11 Manchester Road11 Manchester Road11 Manchester Road11 Manchester Road11 Manchester Road11 Manc...',
            'address_line_two' => 'MerseytownMerseytownMerseytownMerseytownMerseytownMerseytownMerseytownMerseytownMerseytownMerseyt...',
            'city' => 'LiverpoolLiverpoolLiverpoolLiverpoolLiverpoolLiverpoolLiverpoolLiverpoolLiverpoolLiverpoolLiverpo...',
            'postcode' => 'L31 7HD...',
          }
        )

        expect(details.values.map(&:length)).to eq [10, 100, 100, 100, 10]
      end
    end

    context 'with excessive case details' do
      let(:submitted_application) do
        LaaCrimeSchemas.fixture(1.0) do |json|
          json.deep_merge(
            'case_details' => {
              'urn' => 'ABCABCABCABCABCABCABCABCABCABCABCABCABCABCABCABCABCABCABCABC',
            }
          )
        end
      end

      it 'truncates case details' do
        urn = representation.dig('case_details', 'urn')

        expect(urn).to eq 'ABCABCABCABCABCABCABCABCABCABCABCABCABCABCABCAB...'
        expect(urn.length).to eq 50
      end
    end

    context 'with excessive payments details' do
      let(:submitted_application) do
        LaaCrimeSchemas.fixture(1.0) do |json|
          json.merge(
            'means_details' => {
              'income_details' => {
                'income_payments' => [
                  {
                    'payment_type' => 'other',
                    'amount' => 250,
                    'frequency' => 'month',
                    'ownership_type' => 'applicant',
                    'metadata' => {
                      'details' => 'I accidentally pasted an essay into this field' * 25,
                    }
                  }
                ]
              }
            }
          )
        end
      end

      it 'truncates payment details' do
        details = representation.dig('means_details', 'income_details', 'income_payments')[0]

        expect(details['details'].size).to eq 1000
      end
    end

    context 'with excessive properties' do
      let(:submitted_application) do
        LaaCrimeSchemas.fixture(1.0) do |json|
          json.deep_merge(
            'means_details' => {
              'capital_details' => {
                'properties' => [
                  {
                    'property_type' => 'residential',
                    'address' => {
                      'address_line_one' => '50 Regent Street' * 15,
                      'address_line_two' => 'Westminster' * 15,
                      'city' => 'London' * 20,
                      'country' => 'United Kingom' * 20,
                      'postcode' => 'SW7 7ABXXXXXXXX',
                    },
                    'property_owners' => [
                      {
                        'name' => 'Flats R Us' * 30,
                        'other_relationship' => 'Godfather' * 100,
                        'percentage_owned' => 100.0,
                      },
                    ]
                  }
                ]
              },
            }
          )
        end
      end

      # TODO: No idea why the deep_merge causes the `properties` key to replicate the whole `capital_details` hash!
      let(:property) { representation.dig('means_details', 'capital_details', 'properties', 'properties')[0] }

      it 'truncates property address' do
        details = property['address'].slice('address_line_one', 'address_line_two', 'city', 'country', 'postcode')

        expect(details).to eq(
          {
            'address_line_one' => '50 Regent Street50 Regent Street50 Regent Street50 Regent Street50 Regent Street50 Regent Street5...',
            'address_line_two' => 'WestminsterWestminsterWestminsterWestminsterWestminsterWestminsterWestminsterWestminsterWestminst...',
            'city' => 'LondonLondonLondonLondonLondonLondonLondonLondonLondonLondonLondonLondonLondonLondonLondonLondonL...',
            'country' => 'United KingomUnited KingomUnited KingomUnited KingomUnited KingomUnited KingomUnited KingomUnited KingomUnited KingomUnited KingomUnited KingomUnit...',
            'postcode' => 'SW7 7AB...',
          }
        )

        expect(details.values.map(&:length)).to eq [100, 100, 100, 150, 10]
      end

      it 'truncates property owners' do
        details = property['property_owners'][0].slice('name', 'other_relationship')

        expect(details).to eq(
          {
            'name' => 'Flats R UsFlats R UsFlats R UsFlats R UsFlats R UsFlats R UsFlats R UsFlats R UsFlats R UsFlats R UsFlats R UsFlats R UsFlats R UsFlats R UsFlats R UsFlats R UsFlats R UsFlats R UsFlats R UsFlats R UsFlats R UsFlats R UsFlats R UsFlats R UsFlats R UsFl...',
            'other_relationship' => 'GodfatherGodfatherGodfatherGodfatherGodfatherGodfatherGodfatherGodfatherGodfatherGodfatherGodfatherGodfatherGodfatherGodfatherGodfatherGodfatherGodfatherGodfatherGodfatherGodfatherGodfatherGodfatherGodfatherGodfatherGodfatherGodfatherGodfatherGodfather...',
          }
        )

        expect(details.values.map(&:length)).to eq [255, 255]
      end
    end
  end
  # rubocop:enable Layout/LineLength
end
