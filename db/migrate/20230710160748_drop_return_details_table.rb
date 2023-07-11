class DropReturnDetailsTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :return_details, id: :uuid do |t|
      t.string :reason, null: false
      t.text :details
      t.references :crime_application, null: false, foreign_key: true, type: :uuid, unique: true

      t.timestamps
    end
  end
end
