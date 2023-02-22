require 'rails_helper'

describe Events::Submission do
  let(:crime_application) do
    instance_double(CrimeApplication, id: 'f7b429cc')
  end

  it_behaves_like 'an event notification',
                  name: 'apply.submission',
                  message: { id: 'f7b429cc' }
end
