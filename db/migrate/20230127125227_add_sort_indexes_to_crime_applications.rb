class AddSortIndexesToCrimeApplications < ActiveRecord::Migration[7.0]
  def change
    change_table :crime_applications do |t|
      t.virtual(
        :reference,
        type: :integer, as: "(application->>'reference')::int", stored: true
      )
      
      t.virtual(
        :applicant_first_name,
        type: :string, as: "(application#>>'{client_details,applicant,first_name}')", stored: true
      )

      t.virtual(
        :applicant_last_name,
        type: :string, as: "(application#>>'{client_details,applicant,last_name}')", stored: true
      )

      t.change :status, :string
    end

    add_index :crime_applications, :reference
    add_index :crime_applications, [:applicant_last_name, :applicant_first_name], name: 'index_crime_applications_on_applicant_name'
  end
end
