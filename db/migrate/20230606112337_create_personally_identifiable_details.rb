class CreatePersonallyIdentifiableDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :personally_identifiable_details, id: :uuid do |t|
      t.references :crime_application, type: :uuid, foreign_key: true, null: true, index: { unique: true }
      t.jsonb :protected_details, null: false, default: {}
    end
  end
end
