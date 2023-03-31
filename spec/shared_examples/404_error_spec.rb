require 'rails_helper'

RSpec.shared_examples 'an error that raises a 404 status code' do
  it 'returns http status Not Found' do
    expect(response).to have_http_status(:not_found)
  end
end
