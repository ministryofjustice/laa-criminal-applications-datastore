require 'rails_helper'

describe CrimeApplication do
  let(:valid_attributes) do
    { submitted_application: application_attributes }
  end

  let(:application_attributes) do
    JSON.parse(LaaCrimeSchemas.fixture(1.0).read)
  end

  describe '#create' do
    subject(:create) do
      described_class.create!(valid_attributes)
    end

    it 'persists the application' do
      expect { create }.to change(described_class, :count).by 1
    end

    it 'persists the redacted application' do
      expect { create }.to change(RedactedCrimeApplication, :count).by 1
    end

    context 'when a record with the id already exists' do
      before do
        described_class.create!(id: application_attributes['id'])
      end

      it 'raises a RecordNotUnique error' do
        expect { create }.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end

    describe 'the created application' do
      subject(:application) { described_class.find(application_attributes['id']) }

      before { create }

      it 'has the same id as the document' do
        expect(application).not_to be_nil
      end

      it 'has the same `submitted_at` as the document' do
        expect(
          application.submitted_at
        ).to eq(application_attributes['submitted_at'])
      end

      describe 'redacted application' do
        let(:redacted_application) { application.redacted_crime_application }

        it 'has the same status attribute' do
          expect(application.status).to eq(redacted_application.status)
        end
      end

      describe 'Setting the offence class' do
        context 'when offence class cannot be determined' do
          it 'has an offence class' do
            expect(
              application.offence_class
            ).to be_nil
          end
        end

        context 'when offence class can be determined' do
          let(:application_attributes) do
            LaaCrimeSchemas.fixture(1.0) do |json|
              json.deep_merge(
                'case_details' => {
                  # For the sake of this test, only `offence_class` attrs are required
                  'offences' => [{ 'offence_class' => 'C' }, { 'offence_class' => 'F' }]
                }
              )
            end
          end

          it 'has an offence class' do
            expect(
              application.offence_class
            ).to eq 'C'
          end
        end
      end

      describe 'Setting the work stream' do
        it 'has a set work stream' do
          expect(
            application.work_stream
          ).to eq 'criminal_applications_team'
        end
      end

      context 'when application is post submission evidence application' do
        subject(:pse_application) { described_class.find(pse_application_attributes['id']) }

        let(:pse_application_attributes) do
          JSON.parse(LaaCrimeSchemas.fixture(1.0, name: 'post_submission_evidence').read)
        end

        before do
          described_class.create!(submitted_application: pse_application_attributes)
        end

        it 'does not set the overall offence class' do
          expect(
            pse_application.offence_class
          ).to be_nil
        end

        it 'does not copy the first court hearing name' do
          expect(
            pse_application.submitted_application['case_details']
          ).to be_nil
        end

        it 'sets the work stream from the parent application' do
          expect(
            pse_application.work_stream
          ).to eq application_attributes['work_stream']
        end
      end
    end
  end

  describe '#update' do
    subject(:application) { described_class.find(application_attributes['id']) }

    before do
      described_class.create!(valid_attributes)
    end

    let(:redacted_application) { application.redacted_crime_application }

    context 'when updating the status of the application' do
      it 'updates the status' do
        expect do
          application.update!(status: 'returned')
        end.to change(application, :status).from('submitted').to('returned')
      end

      it 'updates the redacted application status' do
        expect(redacted_application.status).to eq('submitted')

        application.update!(status: 'returned')
        redacted_application.reload

        expect(redacted_application.status).to eq('returned')
      end
    end
  end

  # TODO: determine if application_type needs be chached on the model.
  describe '#application_type' do
    subject(:application_type) { described_class.new(valid_attributes).application_type }

    it 'returns the application type from the submitted json' do
      expect(application_type).to eq 'initial'
    end
  end

  describe '#applicant_name' do
    context 'when created' do
      subject!(:application) do
        record = described_class.create!(valid_attributes)
        record.reload
      end

      it 'is stored with correct case' do
        applicant_name = [
          application.applicant_first_name,
          application.applicant_last_name
        ].join(' ')

        expect(applicant_name).to eq 'Kit Pound'
      end

      it 'is searchable with insensitive case' do
        db_record = described_class.where(
          applicant_first_name: 'kIt',
          applicant_last_name: 'pOunD'
        )

        expect(db_record.first).to eq(application)
      end
    end
  end

  describe 'court hearing name' do
    let(:is_first_court_hearing_test_cases) do
      {
        yes: {
          submitted: {
            'hearing_court_name' => 'Westminster',
            'first_court_hearing_name' => nil,
          },
          persisted: {
            'hearing_court_name' => 'Westminster',
            'first_court_hearing_name' => 'Westminster',
          },
        },
        no: {
          submitted: {
            'hearing_court_name' => 'Leicester',
            'first_court_hearing_name' => 'Nottingham',
          },
          persisted: {
            'hearing_court_name' => 'Leicester',
            'first_court_hearing_name' => 'Nottingham',
          },
        },
        no_hearing_yet: {
          submitted: {
            'hearing_court_name' => 'Cardiff',
            'first_court_hearing_name' => nil,
          },
          persisted: {
            'hearing_court_name' => 'Cardiff',
            'first_court_hearing_name' => 'Cardiff',
          },
        }
      }
    end

    context 'with #create!' do
      it 'auto-fills first_court_name as expected', :aggregate_failure do
        is_first_court_hearing_test_cases.each do |is_first_court_hearing, test|
          application_attributes.deep_merge!(
            'id' => SecureRandom.uuid,
            'case_details' => {
              'is_first_court_hearing' => is_first_court_hearing.to_s,
              'hearing_court_name' => test[:submitted]['hearing_court_name'],
              'first_court_hearing_name' => test[:submitted]['first_court_hearing_name'],
            }
          )

          crime_application = described_class.create!({ submitted_application: application_attributes })

          expect(crime_application.reload.submitted_application['case_details']).to include(
            'is_first_court_hearing' => is_first_court_hearing.to_s,
            'hearing_court_name' => test[:persisted]['hearing_court_name'],
            'first_court_hearing_name' => test[:persisted]['first_court_hearing_name']
          )
        end
      end
    end

    context 'with #update!' do
      subject!(:application) do
        described_class.create!({ submitted_application: application_attributes })
      end

      it 'does not change first_court_hearing_name when already set' do
        expect { application.update!(status: 'returned') }.not_to change(application, :submitted_application)
      end

      it 'does not change first_court_hearing_name when is_first_court_hearing = no_hearing_yet' do
        application.submitted_application['case_details']['is_first_court_hearing'] = 'no_hearing_yet'
        application.submitted_application['case_details']['first_court_hearing_name'] = nil
        application.update!(status: 'returned')

        expect(application.submitted_application['case_details']).to include(
          'is_first_court_hearing' => 'no_hearing_yet',
          'first_court_hearing_name' => 'Cardiff Magistrates\' Court'
        )
      end
    end
  end
end
