require 'rails_helper'

RSpec.describe Deleting::MigrateApplications do
  subject(:migrate_applications) { described_class.new }

  let(:event_store) { Rails.configuration.event_store }
  let(:repository) { AggregateRoot::Repository.new(event_store) }
  let(:deletable_entity) { DeletableEntity.first }

  describe 'Submitted application' do
    let(:event_stream) { event_store.read.stream("Deleting$#{submitted_application.reference}").to_a }
    let(:submitted_application) { CrimeApplication.find_by(reference: 6_000_001) }
    let(:deletable) { repository.load(Deleting::Deletable.new, "Deleting$#{submitted_application.reference}") }

    before do
      CrimeApplication.insert_all( # rubocop:disable Rails/SkipsModelValidations
        [
          {
            submitted_application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read),
            status: 'submitted',
            review_status: 'application_received',
            submitted_at: Time.zone.local(2025, 9, 6),
            returned_at: nil,
            reviewed_at: nil
          }
        ]
      )
      migrate_applications.call
    end

    it 'produces a single migration event for a submitted application' do
      expect(event_stream.count).to eq(1)
      expect(event_stream.first.class).to eq(Deleting::ApplicationMigrated)
    end

    it 'produces the right event data for a submitted application' do
      expect(event_stream.first.data).to eq(
        {
          business_reference: submitted_application.reference,
          entity_id: submitted_application.id,
          entity_type: submitted_application.application_type,
          maat_id: nil,
          decision_id: nil,
          overall_decision: nil,
          submitted_at: submitted_application.submitted_at,
          returned_at: submitted_application.returned_at,
          reviewed_at: submitted_application.reviewed_at,
          last_updated_at: submitted_application.submitted_at,
          review_status: submitted_application.review_status
        }
      )
    end

    it 'correctly evaluates the state of a submitted application' do
      expect(deletable.state).to eq(:submitted)
    end

    it 'correctly evaluates the deletion date of a submitted application' do
      expect(deletable.deletion_at).to eq(submitted_application.submitted_at + 2.years)
    end

    it 'creates a deletable entity record with the correct attributes' do
      expect(deletable_entity.business_reference).to eq(submitted_application.reference.to_s)
      expect(deletable_entity.review_deletion_at).to eq(submitted_application.submitted_at + 2.years)
    end
  end

  describe 'Returned application' do
    let(:event_stream) { event_store.read.stream("Deleting$#{returned_application.reference}").to_a }
    let(:returned_application) { CrimeApplication.find_by(reference: 6_000_002) }
    let(:deletable) { repository.load(Deleting::Deletable.new, "Deleting$#{returned_application.reference}") }

    before do
      CrimeApplication.insert_all( # rubocop:disable Rails/SkipsModelValidations
        [
          {
            submitted_application: JSON.parse(LaaCrimeSchemas.fixture(1.0, name: 'application_returned').read),
            status: 'returned',
            review_status: 'returned_to_provider',
            submitted_at: Time.zone.local(2025, 9, 6),
            returned_at: Time.zone.local(2025, 9, 7),
            reviewed_at: Time.zone.local(2025, 9, 7)
          }
        ]
      )
      migrate_applications.call
    end

    it 'produces a single migration event for a returned application' do
      expect(event_stream.count).to eq(1)
      expect(event_stream.first.class).to eq(Deleting::ApplicationMigrated)
    end

    it 'produces the right event data for a returned application' do
      expect(event_stream.first.data).to eq(
        {
          business_reference: returned_application.reference,
          entity_id: returned_application.id,
          entity_type: returned_application.application_type,
          maat_id: nil,
          decision_id: nil,
          overall_decision: nil,
          submitted_at: returned_application.submitted_at,
          returned_at: returned_application.returned_at,
          reviewed_at: returned_application.reviewed_at,
          last_updated_at: returned_application.reviewed_at,
          review_status: returned_application.review_status
        }
      )
    end

    it 'correctly evaluates the state of a returned application' do
      expect(deletable.state).to eq(:returned)
    end

    it 'correctly evaluates the deletion date of a returned application' do
      expect(deletable.deletion_at).to eq(returned_application.reviewed_at + 2.years)
    end

    it 'creates a deletable entity record with the correct attributes' do
      expect(deletable_entity.business_reference).to eq(returned_application.reference.to_s)
      expect(deletable_entity.review_deletion_at).to eq(returned_application.reviewed_at + 2.years)
    end
  end

  describe 'Completed application (no decision)' do
    let(:event_stream) { event_store.read.stream("Deleting$#{completed_application.reference}").to_a }
    let(:completed_application) { CrimeApplication.find_by(reference: 6_000_001) }
    let(:deletable) { repository.load(Deleting::Deletable.new, "Deleting$#{completed_application.reference}") }

    before do
      CrimeApplication.insert_all( # rubocop:disable Rails/SkipsModelValidations
        [
          {
            submitted_application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read),
            status: 'submitted',
            review_status: 'assessment_completed',
            submitted_at: Time.zone.local(2025, 9, 6),
            reviewed_at: Time.zone.local(2025, 9, 7)
          }
        ]
      )
      migrate_applications.call
    end

    it 'produces a single migration event for a completed application' do
      expect(event_stream.count).to eq(1)
      expect(event_stream.first.class).to eq(Deleting::ApplicationMigrated)
    end

    it 'produces the right event data for a completed application' do
      expect(event_stream.first.data).to eq(
        {
          business_reference: completed_application.reference,
          entity_id: completed_application.id,
          entity_type: completed_application.application_type,
          maat_id: nil,
          decision_id: nil,
          overall_decision: nil,
          submitted_at: completed_application.submitted_at,
          returned_at: completed_application.returned_at,
          reviewed_at: completed_application.reviewed_at,
          last_updated_at: completed_application.reviewed_at,
          review_status: completed_application.review_status
        }
      )
    end

    it 'correctly evaluates the state of a completed application' do
      expect(deletable.state).to eq(:completed)
    end

    it 'correctly evaluates the deletion date of a completed application' do
      expect(deletable.deletion_at).to eq(completed_application.reviewed_at + 3.years)
    end

    it 'creates a deletable entity record with the correct attributes' do
      expect(deletable_entity.business_reference).to eq(completed_application.reference.to_s)
      expect(deletable_entity.review_deletion_at).to eq(completed_application.reviewed_at + 3.years)
    end
  end

  describe 'Refused application' do
    let(:event_stream) { event_store.read.stream("Deleting$#{refused_application.reference}").to_a }
    let(:refused_application) { CrimeApplication.find_by(reference: 6_000_001) }
    let(:deletable) { repository.load(Deleting::Deletable.new, "Deleting$#{refused_application.reference}") }

    before do
      CrimeApplication.insert_all( # rubocop:disable Rails/SkipsModelValidations
        [
          {
            submitted_application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read),
            status: 'submitted',
            review_status: 'assessment_completed',
            submitted_at: Time.zone.local(2025, 9, 6),
            reviewed_at: Time.zone.local(2025, 9, 7)
          }
        ]
      )
      refused_application.decisions.create!(
        maat_id: 7_654_321,
        interests_of_justice: {
          result: 'passed',
          details: nil,
          assessed_by: 'Caseworker',
          assessed_on: Time.zone.local(2025, 9, 7)
        },
        means: {
          result: 'failed',
          assessed_by: 'Caseworker',
          assessed_on: Time.zone.local(2025, 9, 7)
        },
        funding_decision: 'refused',
        comment: nil,
        case_id: 'TS00824110814082327',
        assessment_rules: 'magistrates_court',
        overall_result: 'refused_failed_means'
      )
      migrate_applications.call
    end

    it 'produces a single migration event for a refused application' do
      expect(event_stream.count).to eq(1)
      expect(event_stream.first.class).to eq(Deleting::ApplicationMigrated)
    end

    it 'produces the right event data for a refused application' do
      expect(event_stream.first.data).to eq(
        {
          business_reference: refused_application.reference,
          entity_id: refused_application.id,
          entity_type: refused_application.application_type,
          maat_id: refused_application.decisions.first.maat_id,
          decision_id: refused_application.decisions.first.id,
          overall_decision: refused_application.decisions.first.overall_result,
          submitted_at: refused_application.submitted_at,
          returned_at: refused_application.returned_at,
          reviewed_at: refused_application.reviewed_at,
          last_updated_at: refused_application.reviewed_at,
          review_status: refused_application.review_status
        }
      )
    end

    it 'correctly evaluates the state of a refused application' do
      expect(deletable.state).to eq(:completed)
    end

    it 'correctly evaluates the deletion date of a refused application' do
      expect(deletable.deletion_at).to eq(refused_application.reviewed_at + 3.years)
    end

    it 'creates a deletable entity record with the correct attributes' do
      expect(deletable_entity.business_reference).to eq(refused_application.reference.to_s)
      expect(deletable_entity.review_deletion_at).to eq(refused_application.reviewed_at + 3.years)
    end
  end

  describe 'Granted application' do
    let(:event_stream) { event_store.read.stream("Deleting$#{granted_application.reference}").to_a }
    let(:granted_application) { CrimeApplication.find_by(reference: 6_000_001) }
    let(:deletable) { repository.load(Deleting::Deletable.new, "Deleting$#{granted_application.reference}") }

    before do
      CrimeApplication.insert_all( # rubocop:disable Rails/SkipsModelValidations
        [
          {
            submitted_application: JSON.parse(LaaCrimeSchemas.fixture(1.0).read),
            status: 'submitted',
            review_status: 'assessment_completed',
            submitted_at: Time.zone.local(2025, 9, 6),
            reviewed_at: Time.zone.local(2025, 9, 7)
          }
        ]
      )
      granted_application.decisions.create!(
        maat_id: 7_654_321,
        interests_of_justice: {
          result: 'passed',
          details: nil,
          assessed_by: 'Caseworker',
          assessed_on: Time.zone.local(2025, 9, 7)
        },
        means: {
          result: 'passed_with_contribution',
          assessed_by: 'Caseworker',
          assessed_on: Time.zone.local(2025, 9, 7)
        },
        funding_decision: 'granted',
        comment: nil,
        case_id: 'TS00824110814402322',
        assessment_rules: 'crown_court',
        overall_result: 'granted_with_contribution'
      )
      migrate_applications.call
    end

    it 'produces a single migration event for a granted application' do
      expect(event_stream.count).to eq(1)
      expect(event_stream.first.class).to eq(Deleting::ApplicationMigrated)
    end

    it 'produces the right event data for a granted application' do
      expect(event_stream.first.data).to eq(
        {
          business_reference: granted_application.reference,
          entity_id: granted_application.id,
          entity_type: granted_application.application_type,
          maat_id: granted_application.decisions.first.maat_id,
          decision_id: granted_application.decisions.first.id,
          overall_decision: granted_application.decisions.first.overall_result,
          submitted_at: granted_application.submitted_at,
          returned_at: granted_application.returned_at,
          reviewed_at: granted_application.reviewed_at,
          last_updated_at: granted_application.reviewed_at,
          review_status: granted_application.review_status
        }
      )
    end

    it 'correctly evaluates the state of a granted application' do
      expect(deletable.state).to eq(:completed)
    end

    it 'correctly evaluates the deletion date of a granted application' do
      expect(deletable.deletion_at).to eq(granted_application.reviewed_at + 7.years)
    end

    it 'creates a deletable entity record with the correct attributes' do
      expect(deletable_entity.business_reference).to eq(granted_application.reference.to_s)
      expect(deletable_entity.review_deletion_at).to eq(granted_application.reviewed_at + 7.years)
    end
  end

  describe 'Application with superseded versions' do
    let(:event_stream) { event_store.read.stream("Deleting$#{latest_application.reference}").to_a }
    let(:latest_application) { CrimeApplication.where(reference: 6_000_002).order(submitted_at: :desc).first }

    before do
      CrimeApplication.insert_all( # rubocop:disable Rails/SkipsModelValidations
        [
          {
            submitted_application: { reference: 6_000_002, application_type: 'initial' },
            status: 'superseded',
            review_status: 'returned_to_provider',
            submitted_at: Time.zone.local(2025, 9, 4),
            returned_at: Time.zone.local(2025, 9, 5),
            reviewed_at: Time.zone.local(2025, 9, 5)
          },
          {
            submitted_application: { reference: 6_000_002, application_type: 'initial' },
            status: 'superseded',
            review_status: 'returned_to_provider',
            submitted_at: Time.zone.local(2025, 9, 5),
            returned_at: Time.zone.local(2025, 9, 6),
            reviewed_at: Time.zone.local(2025, 9, 6)
          },
          {
            submitted_application: JSON.parse(LaaCrimeSchemas.fixture(1.0, name: 'application_returned').read),
            status: 'returned',
            review_status: 'returned_to_provider',
            submitted_at: Time.zone.local(2025, 9, 6),
            returned_at: Time.zone.local(2025, 9, 7),
            reviewed_at: Time.zone.local(2025, 9, 7)
          }
        ]
      )
      migrate_applications.call
    end

    it 'uses data from the latest application' do # rubocop:disable RSpec/ExampleLength
      expect(event_stream.count).to eq(1)
      expect(event_stream.first.class).to eq(Deleting::ApplicationMigrated)
      expect(event_stream.first.data).to eq(
        {
          business_reference: latest_application.reference,
          entity_id: latest_application.id,
          entity_type: latest_application.application_type,
          maat_id: nil,
          decision_id: nil,
          overall_decision: nil,
          submitted_at: latest_application.submitted_at,
          returned_at: latest_application.returned_at,
          reviewed_at: latest_application.reviewed_at,
          last_updated_at: latest_application.reviewed_at,
          review_status: latest_application.review_status
        }
      )
    end
  end
end
