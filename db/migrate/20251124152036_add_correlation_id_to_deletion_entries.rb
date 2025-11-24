class AddCorrelationIdToDeletionEntries < ActiveRecord::Migration[7.2]
  def change
    add_column :deletion_entries, :correlation_id, :uuid
  end
end
