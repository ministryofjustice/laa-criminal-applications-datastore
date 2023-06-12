class AddMetadataToRedactedTable < ActiveRecord::Migration[7.0]
  def change
    add_column :redacted_crime_applications, :metadata, :jsonb, null: false, default: {}

    add_column(
      :redacted_crime_applications, :status, :virtual,
      as: "(metadata->>'status')", type: :string, stored: true
    )

    add_index :redacted_crime_applications, :status
  end
end
