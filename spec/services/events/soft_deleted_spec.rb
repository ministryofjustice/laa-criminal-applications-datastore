require 'rails_helper'

describe Events::SoftDeleted do
  let(:crime_application) do
    instance_double(
      CrimeApplication,
      reference: 673_209,
      soft_deleted_at: DateTime.parse('2024-06-01')
    )
  end

  it_behaves_like 'an event notification',
                  name: 'Deleting::SoftDeleted',
                  message: {
                    soft_deleted_at: DateTime.parse('2024-06-01'),
                    reference: 673_209,
                    reason: Types::DeletionReason['retention_rule'],
                    deleted_by: 'system_automated'
                  }
end
