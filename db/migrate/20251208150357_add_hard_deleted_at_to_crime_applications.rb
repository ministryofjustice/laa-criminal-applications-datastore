class AddHardDeletedAtToCrimeApplications < ActiveRecord::Migration[7.2]
  def change
    add_column :crime_applications, :hard_deleted_at, :timestamp
  end
end
