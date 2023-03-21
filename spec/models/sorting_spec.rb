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

    # Sorting strings on BSD/MacOSX results in undesirable behaviour
    # https://dba.stackexchange.com/questions/106964/why-is-my-postgresql-order-by-case-insensitive
    context 'with compound sort of applicant name' do
      let(:params) { { sort_by: :applicant_name } }

      it 'orders using postgres lower function' do
        expect(scope).to have_received(:order).with(
          'lower(applicant_last_name) desc, lower(applicant_first_name) desc'
        )
      end
    end
  end
end
