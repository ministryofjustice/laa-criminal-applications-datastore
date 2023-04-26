require 'rails_helper'

RSpec.describe 'Root' do
  describe 'index' do
    it 'has the expected response' do
      get root_url

      expect(response).to have_http_status(:ok)
      expect(response.body).to be_empty
    end
  end
end
