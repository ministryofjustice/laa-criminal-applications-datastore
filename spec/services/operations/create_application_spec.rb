require 'rails_helper'

RSpec.describe Operations::CreateApplication do
  subject(:create_application) { described_class.new(payload:).call }

  let(:event_store) { Rails.configuration.event_store }
  let(:base_payload) { JSON.parse(LaaCrimeSchemas.fixture(1.0).read) }

  context 'when the submitted application includes a slipstream audit selection outcome' do
    let(:payload) { base_payload }
    let(:reference) { payload.fetch('reference') }
    let(:outcome_data) { payload.fetch('slipstream_audit_selection_outcome') }

    it 'creates a single final-state read model row for the application' do
      expect { create_application }.to change(SlipstreamAuditSelectionOutcome, :count).by(1)
    end

    it 'projects the outcome and lifecycle metadata onto the read model' do
      create_application
      outcome = SlipstreamAuditSelectionOutcome.find_by(business_reference: reference)

      expect(outcome).to have_attributes(
        crime_application_id: payload.fetch('id'),
        status: outcome_data.fetch('status'),
        sample_rate: outcome_data.fetch('sample_rate'),
        office_code: payload.dig('provider_details', 'office_code'),
        application_type: payload.fetch('application_type')
      )
    end

    it 'links a SlipstreamAuditSelectionRecorded event to the application audit stream' do
      create_application
      stream = event_store.read.stream(Auditing.stream_name(reference)).to_a

      expect(stream.map(&:class)).to eq([Auditing::SlipstreamAuditSelectionRecorded])
    end
  end

  context 'when the same application reference is resubmitted' do
    let(:payload) { base_payload }
    let(:reference) { payload.fetch('reference') }

    it 'updates the existing final-state row rather than duplicating it' do
      create_application

      resubmission = base_payload.merge(
        'id' => SecureRandom.uuid,
        'slipstream_audit_selection_outcome' =>
          base_payload.fetch('slipstream_audit_selection_outcome').merge('status' => 'withdrawn')
      )

      expect { described_class.new(payload: resubmission).call }
        .not_to change(SlipstreamAuditSelectionOutcome, :count)

      outcome = SlipstreamAuditSelectionOutcome.find_by(business_reference: reference)
      expect(outcome).to have_attributes(status: 'withdrawn', crime_application_id: resubmission.fetch('id'))
    end
  end

  context 'when the submitted application has no slipstream audit selection outcome' do
    let(:payload) { base_payload.except('slipstream_audit_selection_outcome') }

    it 'does not create a read model row' do
      expect { create_application }.not_to change(SlipstreamAuditSelectionOutcome, :count)
    end

    it 'still stores the application' do
      expect { create_application }.to change(CrimeApplication, :count).by(1)
    end
  end
end
