require 'rails_helper'

describe Redacting::Redact do
  subject { described_class.new(crime_application) }

  let(:crime_application) { CrimeApplication.new(submitted_application:) }
  let(:means_details) { JSON.parse(LaaCrimeSchemas.fixture(1.0, name: 'means').read) }
  let(:submitted_application) do
    JSON.parse(LaaCrimeSchemas.fixture(1.0).read).deep_merge('means_details' => means_details)
  end
  let(:redacted_application) { crime_application.redacted_crime_application.submitted_application }

  # rubocop:disable Layout/FirstHashElementIndentation, RSpec/ExampleLength
  describe 'redacting of a submitted application' do
    before { subject.process! }

    context 'with provider details' do
      let(:provider_details) { redacted_application['provider_details'] }

      it 'redacts the expected attributes' do
        expect(provider_details).to eq({
                                         'office_code' => '1A123B',
                                         'provider_email' => '__redacted__',
                                         'legal_rep_first_name' => '__redacted__',
                                         'legal_rep_has_partner_declaration' => 'no',
                                         'legal_rep_last_name' => '__redacted__',
                                         'legal_rep_no_partner_declaration_reason' => 'A reason',
                                         'legal_rep_telephone' => '__redacted__'
                                       })
      end
    end

    context 'with client details' do
      let(:client_details) { redacted_application['client_details'] }

      it 'redacts the expected applicant attributes' do
        expect(client_details['applicant']).to eq({
                                                    'first_name' => '__redacted__',
                                                    'last_name' => '__redacted__',
                                                    'other_names' => '',
                                                    'nino' => '__redacted__',
                                                    'date_of_birth' => '__redacted__',
                                                    'telephone_number' => '__redacted__',
                                                    'correspondence_address_type' => 'home_address',
                                                    'home_address' => {
                                                      'lookup_id' => nil,
                                                      'address_line_one' => '__redacted__',
                                                      'address_line_two' => '__redacted__',
                                                      'city' => '__redacted__',
                                                      'country' => '__redacted__',
                                                      'postcode' => '__redacted__'
                                                    },
                                                    'benefit_type' => 'universal_credit',
                                                    'last_jsa_appointment_date' => nil,
                                                    'correspondence_address' => nil,
                                                    'preferred_correspondence_language' => nil,
                                                    'residence_type' => nil,
                                                    'relationship_to_owner_of_usual_home_address' => nil,
                                                    'has_partner' => 'yes',
                                                    'relationship_status' => nil,
                                                    'relationship_to_partner' => 'living_together',
                                                    'separation_date' => nil,
                                                    'benefit_check_status' => 'no_record_found',
                                                    'benefit_check_result' => false,
                                                    'confirm_details' => 'yes',
                                                    'confirm_dwp_result' => 'no',
                                                    'has_arc' => nil,
                                                    'has_benefit_evidence' => 'no',
                                                    'has_nino' => 'yes',
                                                    'will_enter_nino' => nil,
                                                    'arc' => nil
                                                  })
      end

      it 'redacts the expected partner attributes' do
        expect(client_details['partner']).to eq({
                                                  'first_name' => '__redacted__',
                                                  'last_name' => '__redacted__',
                                                  'other_names' => '__redacted__',
                                                  'has_nino' => 'yes',
                                                  'nino' => '__redacted__',
                                                  'has_arc' => nil,
                                                  'arc' => nil,
                                                  'date_of_birth' => '__redacted__',
                                                  'involvement_in_case' => 'codefendant',
                                                  'conflict_of_interest' => 'no',
                                                  'has_same_address_as_client' => 'no',
                                                  'is_included_in_means_assessment' => false,
                                                  'benefit_check_result' => nil,
                                                  'benefit_check_status' => nil,
                                                  'benefit_type' => nil,
                                                  'confirm_details' => nil,
                                                  'confirm_dwp_result' => nil,
                                                  'has_benefit_evidence' => nil,
                                                  'will_enter_nino' => nil,
                                                  'last_jsa_appointment_date' => nil,
                                                  'home_address' => {
                                                    'lookup_id' => nil,
                                                    'address_line_one' => '__redacted__',
                                                    'address_line_two' => '__redacted__',
                                                    'city' => '__redacted__',
                                                    'country' => '__redacted__',
                                                    'postcode' => '__redacted__'
                                                  },
                                                })
      end
    end

    context 'with means details' do
      let(:redacted_means_details) { redacted_application['means_details'] }

      let(:self_employed_business) do
        {
          'ownership_type' => 'applicant',
          'business_type' => 'self_employed',
          'trading_name' => 'Self employed business 1',
          'address' => {
            'address_line_one' => 'address_line_one_x',
            'address_line_two' => 'address_line_two_x',
            'city' => 'city_x',
            'postcode' => 'postcode_x',
            'country' => 'country_x'
          },
          'description' => 'A cafe',
          'trading_start_date' => 'Sat, 12 Jun 2021',
          'has_additional_owners' => 'yes',
          'additional_owners' => 'Owner 1',
          'has_employees' => 'no',
          'number_of_employees' => nil,
        }
      end

      let(:submitted_application) do
        super().deep_merge('means_details' => { 'income_details' => { 'businesses' => [self_employed_business] } })
      end

      it 'redacts the expected business attributes' do
        business = redacted_means_details['income_details']['businesses'].first
        expect(business).to include(
          'trading_name' => '__redacted__',
          'trading_start_date' => '__redacted__',
          'address' => '__redacted__',
          'additional_owners' => '__redacted__'
        )
      end

      it 'redacts the expected employment attributes' do
        employment = redacted_means_details['income_details']['employments'].first
        expect(employment).to include(
          'employer_name' => '__redacted__',
          'job_title' => 'Supervisor',
          'address' => '__redacted__',
        )
      end

      it 'redacts the expected outgoings attributes' do
        outgoing = redacted_means_details['outgoings_details']['outgoings'].last
        expect(outgoing).to include(
          'payment_type' => 'board_and_lodging',
          'metadata' => '__redacted__'
        )
      end

      it 'redacts the expected capital attributes' do
        expect(redacted_means_details['capital_details']).to include(
          'premium_bonds_holder_number' => '__redacted__',
          'premium_bonds_total_value' => 100_000,
          'partner_premium_bonds_holder_number' => nil,
          'partner_premium_bonds_total_value' => nil
        )
      end

      it 'redacts the expected property address and owners attributes' do
        property = redacted_means_details['capital_details']['properties'].first
        expect(property).to include(
          'address' => '__redacted__',
          'property_owners' => '__redacted__'
        )
      end

      it 'redacts the expected savings attributes' do
        saving = redacted_means_details['capital_details']['savings'].first
        expect(saving).to include(
          'sort_code' => '__redacted__',
          'account_number' => '__redacted__'
        )
      end

      it 'redacts the expected national savings certificate attributes' do
        national_savings_certificate = redacted_means_details['capital_details']['national_savings_certificates'].first
        expect(national_savings_certificate).to include(
          'holder_number' => '__redacted__',
          'certificate_number' => '__redacted__'
        )
      end

      it 'redacts the expected investments attributes' do
        investment = redacted_means_details['capital_details']['investments'].first
        expect(investment).to include('description' => '__redacted__')
      end
    end

    context 'with case details' do
      let(:case_details) { redacted_application['case_details'] }
      let(:submitted_application) do
        super().deep_merge('case_details' => {
          'client_other_charge' => {
            'charge' => 'Theft',
            'hearing_court_name' => "Cardiff Magistrates' Court",
            'next_hearing_date' => '2025-01-15'
          },
          'partner_other_charge' => {
            'charge' => 'Fraud',
            'hearing_court_name' => "Barkingside Magistrates' Court",
            'next_hearing_date' => '2025-02-09'
          },
          'urn' => '12AB3456789'
        })
      end

      it 'redacts the expected attributes' do
        expect(case_details).to include(
          'urn' => '__redacted__',
          'hearing_court_name' => '__redacted__',
          'hearing_date' => '__redacted__',
          'first_court_hearing_name' => '__redacted__',
          'client_other_charge' => {
            'charge' => 'Theft',
            'hearing_court_name' => '__redacted__',
            'next_hearing_date' => '__redacted__'
          },
          'partner_other_charge' => {
            'charge' => 'Fraud',
            'hearing_court_name' => '__redacted__',
            'next_hearing_date' => '__redacted__'
          },
          'codefendants' => [{
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
             'reason' => '__redacted__'
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
             'scan_at' => '2023-10-01 12:34:56'
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

    context 'with date_stamp_context' do
      it 'redacts the expected attributes' do
        expect(redacted_application['date_stamp_context']).to include(
          'first_name' => '__redacted__',
          'last_name' => '__redacted__'
        )
      end
    end
  end

  describe 'metadata attributes' do
    let(:metadata) { crime_application.redacted_crime_application.metadata }

    before { subject.process! }

    it 'contains the expected metadata json' do
      expect(metadata).to eq({
                               'status' => 'submitted',
                               'reviewed_at' => nil,
                               'returned_at' => nil,
                               'review_status' => 'application_received',
                               'offence_class' => nil,
                               'return_reason' => nil,
                               'application_type' => 'initial',
                               'created_at' => nil,
                               'office_code' => nil,
                               'work_stream' => 'criminal_applications_team',
                               'submitted_at' => nil
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
                           'telephone_number' => '__redacted__'
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
      let(:rules) { { 'provider_details' => {} } }

      it 'raises a key not found error' do
        expect { subject.process! }.to raise_error(KeyError, /key not found: :redact/)
      end
    end

    context 'when the `type` is unrecognised' do
      let(:rules) { { 'provider_details' => { redact: %w[], type: :date } } }

      it 'raises a key not found error' do
        expect { subject.process! }.to raise_error(RuntimeError, /unknown rule path type: date/)
      end
    end
  end
end
