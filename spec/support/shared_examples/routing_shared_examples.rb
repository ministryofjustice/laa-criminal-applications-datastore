require 'rails_helper'

RSpec.shared_examples 'an authorisable endpoint' do |consumers|
  let(:authorised_consumers) do
    request.env['grape.routing_args'][:route_info].settings[:authorised_consumers]
  end

  it 'declares authorised consumers' do
    expect(authorised_consumers).to match_array(consumers)
  end
end
