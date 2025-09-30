require 'rails_helper'

RSpec.shared_examples 'an application with events' do
  it 'has the relevant events' do
    event_types = []
    (0..events.length - 1).step(3) do |i|
      event_types << events[i].to_s
    end
    expect(events_in_stream.map(&:event_type)).to include(*event_types)
  end
end
