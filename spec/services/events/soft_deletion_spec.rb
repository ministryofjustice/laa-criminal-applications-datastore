require 'rails_helper'

describe Events::SoftDeletion do
  let(:crime_application) do
    instance_double(
      CrimeApplication,
      id: 'f7b429cc',
      reference: 673_209,
      soft_deleted_at: DateTime.parse('2024-06-01')
    )
  end

  it_behaves_like 'an event notification',
                  name: 'datastore.soft_deletion',
                  message: {
                    id: 'f7b429cc',
                    soft_deleted_at: DateTime.parse('2024-06-01'),
                    reference: 673_209,
                    reason: Types::DeletionReason['retention_rule'],
                    deleted_by: 'system_automated'
                  }
end
