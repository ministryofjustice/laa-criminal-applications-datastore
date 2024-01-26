class AddApplicationTypeVirtualAttributeToCrimeApplications < ActiveRecord::Migration[7.0]
  def change
    add_column(
      :crime_applications,
      :application_type,
      :virtual,
      as: "(submitted_application->>'application_type')",
      type: :string,
      stored: true
    )

    add_index :crime_applications, :application_type
  end
end
