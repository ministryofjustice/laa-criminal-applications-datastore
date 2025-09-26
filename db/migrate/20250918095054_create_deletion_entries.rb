class CreateDeletionEntries < ActiveRecord::Migration[7.2]
  def change
    create_table :deletion_entries, id: :uuid do |t|
      t.string :record_id, null: false
      t.string :record_type, null: false
      t.string :business_reference
      t.string :deleted_by, null: false
      t.string :deleted_from
      t.string :reason, null: false

      t.timestamps
    end
  end
end
