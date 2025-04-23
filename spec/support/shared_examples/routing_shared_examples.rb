require 'rails_helper'

RSpec.shared_examples 'an authorisable endpoint' do |consumers|
  let(:authorised_consumers) do
    request.env['grape.routing_args'][:route_info].settings[:authorised_consumers]
  end

  it 'declares authorised consumers' do
    expect(authorised_consumers).to match_array(consumers)
  end
end

RSpec.shared_context 'with a consumer' do
  before do
    allow_any_instance_of(ActionDispatch::Request).to receive(:env).and_wrap_original do |original, *args|
      original.call(*args).merge('grape_jwt.payload' => { 'iss' => consumer })
    end
  end
end
