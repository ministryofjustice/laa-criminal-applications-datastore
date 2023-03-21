require 'rails_helper'

describe CrimeApplication do
  let(:valid_attributes) do
    { application: application_attributes }
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
end
