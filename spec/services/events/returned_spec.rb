require 'rails_helper'

describe Events::Returned do
  let(:crime_application) do
    instance_double(CrimeApplication, id: 'f7b429cc')
  end

  it_behaves_like 'an event notification',
                  name: 'review.returned',
                  message: { id: 'f7b429cc' }
end
