require 'rails_helper'

RSpec.shared_context 'with published events' do
  let(:event_store) { Rails.configuration.event_store }
  let(:events) { [] }
  let(:event_stream) { '' }
  let(:events_in_stream) do
    event_store.read.stream(event_stream)
  end

  def publish_events
    events.each_slice(3) do |slice|
      event_class = slice[0]
      timestamp = slice[1]
      data = slice[2]
      event_store.with_metadata(timestamp:) do
        event_store.publish(event_class.new(data:))
      end
    end
  end
end
