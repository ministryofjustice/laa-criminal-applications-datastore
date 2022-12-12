class AddStatusAttributesAndIndexesToCrimeApplications < ActiveRecord::Migration[7.0]
  def change
    add_column(:crime_applications, "status", :text, null: false, default: 'submitted', index: true)
    add_column(:crime_applications, :submitted_at, :timestamp, default: -> { 'CURRENT_TIMESTAMP' })
    add_column(:crime_applications, :returned_at, :timestamp)

    add_index(:crime_applications, [:status, :submitted_at], order: { submitted_at: :desc})
    add_index(:crime_applications, [:status, :returned_at], order: { returned_at: :desc})
  end
end
