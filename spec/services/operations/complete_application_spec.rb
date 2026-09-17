require 'rails_helper'

RSpec.describe Operations::CompleteApplication do
  subject(:complete_application) do
    described_class.new(application_id: application.id, decisions: decisions).call
  end

  let(:payload) { JSON.parse(LaaCrimeSchemas.fixture(1.0).read) }
  let(:reference) { payload.fetch('reference') }
  let(:application) { CrimeApplication.find_by(reference:) }

  let(:decisions) do
    [
      {
        'reference' => reference,
        'maat_id' => 987_654,
        'case_id' => '123123123',
        'interests_of_justice' => {
          'result' => 'passed',
          'details' => 'decision details',
          'assessed_by' => 'Grace Nolan',
          'assessed_on' => '2024-10-01'
        },
        'means' => nil,
        'funding_decision' => 'granted',
        'comment' => 'test comment',
        'assessment_rules' => 'appeal_to_crown_court',
        'overall_result' => 'granted_failed_means'
      }
    ]
  end

  before { Operations::CreateApplication.new(payload:).call }

  context 'when the application was slipstream-audited at submission' do
    it 'projects the MAAT reference and IoJ outcome onto the existing read model row' do
      complete_application
      outcome = SlipstreamAuditSelectionOutcome.find_by(business_reference: reference)

      expect(outcome).to have_attributes(maat_reference: 987_654, ioj_outcome: 'passed')
    end

    it 'does not create a duplicate read model row' do
      expect { complete_application }.not_to change(SlipstreamAuditSelectionOutcome, :count)
    end
  end

  context 'when the application was not slipstream-audited at submission' do
    let(:payload) { super().except('slipstream_audit_selection_outcome') }

    it 'does not create a read model row' do
      expect { complete_application }.not_to change(SlipstreamAuditSelectionOutcome, :count)
    end
  end
end
