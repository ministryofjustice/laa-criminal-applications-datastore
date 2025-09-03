require_relative 'spec_helper'

NotDeletingEvent = Class.new(RailsEventStore::Event)

RSpec.describe Deleting do
  let(:event_store) { Rails.configuration.event_store }
  let(:business_reference) { '123ABC' }

  let(:deletion_effecting_events) do
    [
      Applying::DraftCreated,
      Applying::DraftUpdated,
      Applying::DraftDeleted,
      Applying::Submitted,
      Deciding::MaatRecordCreated,
      Reviewing::SentBack,
      Reviewing::Completed
    ]
  end

  describe '::EVENTS' do
    it 'returns a list of deletion related events' do
      expect(described_class::EVENTS).to eq deletion_effecting_events
    end
  end

  describe described_class::Configuration do
    before do
      event_classes = deletion_effecting_events + [NotDeletingEvent]

      event_classes.each do |event_class|
        event_store.publish(event_class.new(data: { business_reference: }))
      end

      event_store.publish(deletion_effecting_events.first.new(
                            data: { business_reference: '456DEF' }
                          ))
    end

    let(:events_in_stream) do
      event_store.read.stream("Deleting$#{business_reference}").map(&:event_type)
    end

    it 'links deletion events to the deleting stream for a given business reference' do
      expect(events_in_stream).to eq deletion_effecting_events.map(&:name)
    end
  end
end
