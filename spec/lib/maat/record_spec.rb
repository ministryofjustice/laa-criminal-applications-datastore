require 'rails_helper'

RSpec.describe MAAT::Record do
  describe '.new' do
    subject(:new) { described_class.new(response) }

    let(:response) do
      {
        'usn' => 10,
        'maat_ref' => 600,
        'case_id' => '123123123',
        'case_type' => 'SUMMARY ONLY',
        'ioj_result' => 'PASS',
        'ioj_reason' => 'Details of IoJ',
        'ioj_assessor_name' => 'System Test IoJ',
        'app_created_date' => '2024-09-23T00:00:00',
        'means_result' => 'PASS',
        'means_assessor_name' => 'System Test Means',
        'date_means_created' => '2024-09-23T17:18:56',
        'funding_decision' => 'GRANTED',
        'cc_rep_decision' => 'GRANTED - Passed Means Test',
        'ioj_appeal_result' => 'PASS',
        'ioj_appeal_assessor_name' => 'System Test IoJ Appeal',
        'ioj_appeal_date' => '2024-09-23T19:10:56',
        'passport_result' => 'PASS',
        'passport_assessor_name' => 'System Test Passport',
        'date_passport_created' => '2024-09-23T19:20:56',
        'passport_review_type' => nil,
        'means_review_type' => 'ER',
        'passport_work_reason' => 'FMA',
        'means_work_reason' => 'PAI'
      }
    end

    describe '#usn' do
      subject(:usn) { new.usn }

      it { is_expected.to be 10 }
    end

    describe '#maat_ref' do
      subject(:maat_ref) { new.maat_ref }

      it { is_expected.to be(600) }
    end

    describe '#case_id' do
      subject(:case_id) { new.case_id }

      it { is_expected.to eq('123123123') }
    end

    describe '#case_type' do
      subject(:case_type) { new.case_type }

      it { is_expected.to eq('SUMMARY ONLY') }
    end

    describe '#ioj_result' do
      subject(:ioj_result) { new.ioj_result }

      it { is_expected.to eq('PASS') }
    end

    describe '#ioj_reason' do
      subject(:ioj_reason) { new.ioj_reason }

      it { is_expected.to eq('Details of IoJ') }
    end

    describe '#ioj_assessor_name' do
      subject(:ioj_assessor_name) { new.ioj_assessor_name }

      it { is_expected.to eq('System Test IoJ') }
    end

    describe '#app_created_date' do
      subject(:app_created_date) { new.app_created_date }

      it { is_expected.to eq(DateTime.parse('2024-09-23T00:00:00')) }
    end

    describe '#means_result' do
      subject(:means_result) { new.means_result }

      it { is_expected.to eq('PASS') }
    end

    describe '#means_assessor_name' do
      subject(:means_assessor_name) { new.means_assessor_name }

      it { is_expected.to eq('System Test Means') }
    end

    describe '#date_means_created' do
      subject(:date_means_created) { new.date_means_created }

      it { is_expected.to eq(DateTime.parse('2024-09-23T17:18:56')) }
    end

    describe '#funding_decision' do
      subject(:funding_decision) { new.funding_decision }

      it { is_expected.to eq('GRANTED') }
    end

    describe '#cc_rep_decision' do
      subject(:cc_rep_decision) { new.cc_rep_decision }

      it { is_expected.to eq('GRANTED - Passed Means Test') }
    end

    describe '#ioj_appeal_result' do
      subject(:ioj_appeal_result) { new.ioj_appeal_result }

      it { is_expected.to eq('PASS') }
    end

    describe '#ioj_appeal_assessor_name' do
      subject(:ioj_appeal_assessor_name) { new.ioj_appeal_assessor_name }

      it { is_expected.to eq('System Test IoJ Appeal') }
    end

    describe '#ioj_appeal_date' do
      subject(:ioj_appeal_date) { new.ioj_appeal_date }

      it { is_expected.to eq(DateTime.parse('2024-09-23T19:10:56')) }
    end

    describe '#passport_result' do
      subject(:passport_result) { new.passport_result }

      it { is_expected.to eq('PASS') }
    end

    describe '#passport_assessor_name' do
      subject(:passport_assessor_name) { new.passport_assessor_name }

      it { is_expected.to eq('System Test Passport') }
    end

    describe '#date_passport_created' do
      subject(:date_passport_created) { new.date_passport_created }

      it { is_expected.to eq(DateTime.parse('2024-09-23T19:20:56')) }
    end

    describe '#passport_review_type' do
      subject(:passport_review_type) { new.passport_review_type }

      it { is_expected.to be_nil }
    end

    describe '#means_review_type' do
      subject(:means_review_type) { new.means_review_type }

      it { is_expected.to eq('ER') }
    end

    describe '#passport_work_reason' do
      subject(:passport_work_reason) { new.passport_work_reason }

      it { is_expected.to eq('FMA') }
    end

    describe '#means_work_reason' do
      subject(:means_work_reason) { new.means_work_reason }

      it { is_expected.to eq('PAI') }
    end
  end
end
