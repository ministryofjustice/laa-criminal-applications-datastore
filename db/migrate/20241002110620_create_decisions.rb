class CreateDecisions < ActiveRecord::Migration[7.1]
  def change
    create_table :decisions, id: :uuid do |t|
      t.references :crime_application, type: :uuid, foreign_key: true, null: true, index: { unique: true }
      t.integer :reference
      t.integer :maat_id
      t.jsonb :interests_of_justice
      t.jsonb :means
      t.string :funding_decision, null: false
      t.string :comment

      t.timestamps

    end
  end
end
