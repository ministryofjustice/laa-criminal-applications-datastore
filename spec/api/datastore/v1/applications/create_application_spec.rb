require 'rails_helper'

RSpec.describe 'create application' do
  let(:application_id) { application.submitted_application['id'] }

  let(:application) do
    instance_double(
      CrimeApplication,
      submitted_application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read)
    )
  end
  let(:event_stream) { Rails.configuration.event_store.read }

  describe 'POST /api/applications' do
    subject(:api_request) do
      post '/api/v1/applications', params: { application: payload }
    end

    let(:record) do
      instance_double(CrimeApplication, id: application_id, application_type: 'initial', reference: 6_000_001)
    end
    let(:payload) { LaaCrimeSchemas.fixture(1.0).read }

    let(:submission_event) { instance_double(Events::Submission, publish: true) }

    it_behaves_like 'an authorisable endpoint', %w[crime-apply crime-apply-preprod] do
      before { api_request }
    end

    context 'with a valid request' do
      before do
        allow(CrimeApplication).to receive(:create!).with(
          submitted_application: JSON.parse(payload)
        ).and_return(record)

        allow(
          Operations::SupersedeApplication
        ).to receive(:new).and_return(double.as_null_object)

        allow(
          Events::Submission
        ).to receive(:new).with(record).and_return(submission_event)

        api_request
      end

      it 'stores the application in the datastore' do
        expect(CrimeApplication).to have_received(:create!).with(
          submitted_application: JSON.parse(payload)
        )
      end

      it 'returns http status 201' do
        expect(response).to have_http_status(:created)
      end

      it 'includes the record id in the response body' do
        expect(JSON.parse(response.body)).to match({ 'id' => application_id })
      end

      it 'does not perform superseding on first submissions' do
        expect(Operations::SupersedeApplication).not_to have_received(:new)
      end

      it 'publishes a submission event' do
        expect(
          submission_event
        ).to have_received(:publish)
      end

      it 'publishes an Applying::Submitted event with the expected attributes' do
        event = event_stream.first
        expect(event_stream.map(&:event_type)).to match ['Applying::Submitted']
        expect(event.data).to eq({ entity_id: application_id, entity_type: 'initial',
                                   business_reference: 6_000_001 })
      end

      context 'when is a resubmission' do
        let(:payload) { JSON.dump(JSON.parse(super()).merge('parent_id' => '12345')) }

        it 'supersedes the parent application' do
          expect(
            Operations::SupersedeApplication
          ).to have_received(:new).with(application_id: '12345')
        end

        it 'publishes a submission event' do
          expect(
            submission_event
          ).to have_received(:publish)
        end

        it 'publishes an Applying::Submitted event with the expected attributes' do
          event = event_stream.first
          expect(event_stream.map(&:event_type)).to match ['Applying::Submitted']
          expect(event.data).to eq({ entity_id: application_id, entity_type: 'initial',
                                     business_reference: 6_000_001 })
        end
      end
    end

    context 'when the application already exists' do
      before do
        allow(CrimeApplication).to receive(:create!).with(
          submitted_application: JSON.parse(payload)
        ) { raise ActiveRecord::RecordNotUnique }

        api_request
      end

      it 'returns 409' do
        expect(response).to have_http_status(:conflict)
      end

      it 'returns error information' do
        expect(response.body).to include('Application already submitted')
      end

      it 'does not publish a submission event' do
        expect(
          submission_event
        ).not_to have_received(:publish)
      end

      it 'does not publishes an Applying::Submitted event' do
        expect(event_stream.map(&:event_type)).to match []
      end
    end

    context 'with a schema error' do
      before do
        allow(CrimeApplication).to receive(:create!)
        api_request
      end

      let(:payload) do
        LaaCrimeSchemas.fixture(1.0) { |json| json.merge('reference' => nil) }.to_json
      end

      it 'does not store the application' do
        expect(CrimeApplication).not_to have_received(:create!)
      end

      it 'returns 400' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns error information' do
        expect(response.body).to include(
          "The property '#/reference' of type null did not match the following type: integer in schema"
        )
      end

      it 'does not publishes an Applying::Submitted event' do
        expect(event_stream.map(&:event_type)).to match []
      end
    end
  end
end
