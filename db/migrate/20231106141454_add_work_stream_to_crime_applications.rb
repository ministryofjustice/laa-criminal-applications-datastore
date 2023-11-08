class AddWorkStreamToCrimeApplications < ActiveRecord::Migration[7.0]
  def change
    add_column :crime_applications, :work_stream, :string, null: false, default: 'criminal_applications_team'
    add_index :crime_applications, :work_stream
  end
end
