class AddArchivedAtToCrimeApplications < ActiveRecord::Migration[7.1]
  def change
    change_table :crime_applications, bulk: true do |t|
      t.timestamp :archived_at
      t.index :archived_at, where: 'archived_at IS NULL'
    end
  end
end
