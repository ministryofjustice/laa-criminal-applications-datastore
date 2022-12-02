namespace :indexes do
  task StatusSubmittedAtIndex: :environment do
    unless has_gsi_index?(name: 'StatusSubmittedAtIndex')
      Dynamoid.adapter.client.update_table(
        table_name: ::Dynamodb::CrimeApplication.table_name,
        attribute_definitions: [
          { attribute_name: 'status', attribute_type: 'S' },
          { attribute_name: 'submitted_at', attribute_type: 'S' },
        ],
        global_secondary_index_updates: [
          create: {
            index_name: 'StatusSubmittedAtIndex',
            key_schema: [
              { attribute_name: 'status', key_type: 'HASH' },
              { attribute_name: 'submitted_at', key_type: 'RANGE' },
            ],
            projection: {
              projection_type: 'ALL'
            },
            provisioned_throughput: {
              read_capacity_units: 1,
              write_capacity_units: 1
            }
          }
        ]
      )
    end
  end

  private

  def has_gsi_index?(table_name: ::Dynamodb::CrimeApplication.table_name, name:)
    output = Dynamoid.adapter.client.describe_table(table_name:)

    if output.table.global_secondary_indexes.to_a.pluck(:index_name).include?(name)
      puts "Table `#{table_name}` already has index #{name}"
      true
    else
      puts "Adding global secondary index #{name} to table `#{table_name}`..."
      false
    end
  end
end
