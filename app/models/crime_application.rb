class CrimeApplication
  include Dynamoid::Document

  # NOTE: once the table is created, changing
  # these values will have no effect
  table name: :crime_applications, key: :id

  field :status
  field :version, :number

  field :created_at,    :datetime
  field :submitted_at,  :datetime
  field :data_stamp,    :datetime

  field :provider_details,      :serialized, serializer: JSON
  field :client_details,        :serialized, serializer: JSON
  field :case_details,          :serialized, serializer: JSON
  field :interests_of_justice,  :serialized, serializer: JSON

  # global_secondary_index hash_key: :status,
  #                        range_key: :submitted_at
end
