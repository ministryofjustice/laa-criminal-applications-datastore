require 'rails_helper'

describe Sorting do
  subject(:sorting) { described_class.new(params) }

  let(:params) { nil }

  describe '#apply_to_scope' do
    subject(:apply_to_scope) { sorting.apply_to_scope(scope) }

    let(:scope) { class_double(CrimeApplication) }

    before do
      allow(scope).to receive(:order)
      apply_to_scope
    end

    context 'with no params' do
      it 'orders by defaults submitted_at:desc' do
        expect(scope).to have_received(:order).with({ submitted_at: :desc })
      end
    end

    context 'when valid sort_direction and sort_by specified' do
      let(:params) { { sort_by: :reviewed_at, sort_direction: :asc } }

      it 'applies specified sorting to scope' do
        expect(scope).to have_received(:order).with({ reviewed_at: :asc })
      end
    end

    context 'with a compound applicant name sort' do
      let(:params) { { sort_by: :applicant_name } }

      it 'orders by both columns' do
        expect(scope).to have_received(:order).with(
          { applicant_last_name: :desc, applicant_first_name: :desc, }
        )
      end
    end

    context 'with a custom sql sort' do
      let(:params) { { sort_by: :application_status, sort_direction: sort_direction } }

      context 'when ascending' do
        let(:sort_direction) { 'descending' }

        it 'orders custom sql' do
          expect(scope).to have_received(:order).with(
            'CASE review_status ' \
            "WHEN 'application_received' THEN 30 " \
            "WHEN 'ready_for_assessment' THEN 30 " \
            "WHEN 'returned_to_provider' THEN 20 " \
            "WHEN 'assessment_completed' THEN 10 " \
            'ELSE 0 END DESC'
          )
        end
      end

      context 'when descending' do
        let(:sort_direction) { 'ascending' }

        it 'orders custom sql' do
          expect(scope).to have_received(:order).with(
            'CASE review_status ' \
            "WHEN 'application_received' THEN 30 " \
            "WHEN 'ready_for_assessment' THEN 30 " \
            "WHEN 'returned_to_provider' THEN 20 " \
            "WHEN 'assessment_completed' THEN 10 " \
            'ELSE 0 END ASC'
          )
        end
      end
    end
  end
end
