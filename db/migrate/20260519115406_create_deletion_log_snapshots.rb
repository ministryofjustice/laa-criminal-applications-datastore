class CreateDeletionLogSnapshots < ActiveRecord::Migration[7.2]
  def change
    create_table :deletion_log_snapshots, id: :uuid do |t|
      t.integer :count
      t.datetime :recorded_at

      t.timestamps
    end
  end
end
