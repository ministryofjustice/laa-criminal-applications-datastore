class AddArchivedToCrimeApplications < ActiveRecord::Migration[7.1]
  def change
    change_table :crime_applications, bulk: true do |t|
      t.boolean :archived, default: false
      t.timestamp :archived_at
      t.index :archived, where: 'archived = false'
    end
  end
end
