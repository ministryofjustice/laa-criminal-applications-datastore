require 'rails_helper'

describe Events::Submission do
  let(:crime_application) do
    instance_double(CrimeApplication, application: { foo: 'bar' })
  end

  it_behaves_like 'an event notification',
                  name: 'apply.submission',
                  message: { foo: 'bar' }
end
