class AddCaseTypeVirtualAttributeToCrimeApplications < ActiveRecord::Migration[7.0]
  def change
    add_column(
      :crime_applications,
      :case_type,
      :virtual,
      as: "(submitted_application->'case_details'->>'case_type')",
      type: :string,
      stored: true
    )

    add_index :crime_applications, :case_type
  end
end
