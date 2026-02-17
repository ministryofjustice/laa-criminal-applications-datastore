require 'rails_helper'

describe Events::Archived do
  let(:crime_application) do
    instance_double(
      CrimeApplication,
      id: 'f7b429cc',
      reference: 673_209,
      application_type: 'initial',
      archived_at: DateTime.parse('2024-06-01')
    )
  end

  it_behaves_like 'an event notification',
                  name: 'Applying::Archived',
                  message: {
                    id: 'f7b429cc',
                    archived_at: DateTime.parse('2024-06-01'),
                    application_type: 'initial',
                    reference: 673_209
                  }
end
