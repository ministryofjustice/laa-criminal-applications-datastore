class CrimeApplication
  include Dynamoid::Document

  TABLE_NAME = ENV.fetch(
    'APPLICATIONS_TABLE_NAME', 'crime_applications'
  ).freeze

  # NOTE: on cloud-platform, table names are not
  # predictable, so we get these from the ENV
  table name: TABLE_NAME, key: :id

  field :schema_version, :number

  field :status
  field :usn, :integer

  field :created_at,    :datetime
  range :submitted_at,  :datetime
  field :date_stamp,    :datetime

  field :provider_details,      :serialized, serializer: JSON
  field :client_details,        :serialized, serializer: JSON
  field :case_details,          :serialized, serializer: JSON
  field :interests_of_justice,  :serialized, serializer: JSON

  global_secondary_index hash_key: :status,
                         range_key: :submitted_at,
                         projected_attributes: :all,
                         name: 'StatusSubmittedAtIndex'

  # Convenience method as dynamoid provided one
  # forces you to always pass the range key.
  def self.find(id, **options)
    return super if options[:range_key]

    where(id:).first || raise(Dynamoid::Errors::RecordNotFound)
  end
end
