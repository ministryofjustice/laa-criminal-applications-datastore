require 'rails_helper'

describe Events::Returned do
  let(:crime_application) do
    instance_double(CrimeApplication, application: { foo: 'bar' })
  end

  it_behaves_like 'an event notification',
                  name: 'review.returned',
                  message: { foo: 'bar' }
end
