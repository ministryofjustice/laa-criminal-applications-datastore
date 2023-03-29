require 'rails_helper'

RSpec.shared_examples 'raises a 409 error' do
  it 'raises a 409 error' do
    api_request
    expect(response).to have_http_status :conflict
  end
end
