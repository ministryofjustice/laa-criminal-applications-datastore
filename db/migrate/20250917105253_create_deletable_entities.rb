class CreateDeletableEntities < ActiveRecord::Migration[7.2]
  def change
    create_table :deletable_entities, id: :uuid do |t|
      t.string :business_reference, index: { unique: true }
      t.datetime :review_deletion_at
      t.timestamps
    end
  end
end
