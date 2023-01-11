class AddCompletedAtToCrimeApplications < ActiveRecord::Migration[7.0]
  def change
    add_column(:crime_applications, :completed_at, :timestamp)
    add_index(:crime_applications, [:status, :completed_at], order: { completed_at: :desc})
  end
end
