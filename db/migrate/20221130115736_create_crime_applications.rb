class CreateCrimeApplications < ActiveRecord::Migration[7.0]
  def change
    create_table :crime_applications, id: :uuid do |t|
      t.jsonb :application

      t.timestamps
    end
  end
end
