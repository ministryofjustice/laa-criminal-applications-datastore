require 'rails_helper'

describe Events::Submission do
  let(:crime_application) do
    instance_double(
      CrimeApplication,
      id: 'f7b429cc',
      submitted_at: DateTime.parse('2023-02-27'),
      reference: 673_209,
      submitted_application: { 'parent_id' => '9a123b' },
      work_stream: 'extradition',
      application_type: 'initial'
    )
  end

  it_behaves_like 'an event notification',
                  name: 'apply.submission',
                  message: {
                    id: 'f7b429cc',
                    submitted_at: DateTime.parse('2023-02-27'),
                    parent_id: '9a123b',
                    work_stream: 'extradition',
                    application_type: 'initial'
                  }
end
