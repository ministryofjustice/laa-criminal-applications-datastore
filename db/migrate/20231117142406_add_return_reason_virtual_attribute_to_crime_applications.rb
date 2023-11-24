class AddReturnReasonVirtualAttributeToCrimeApplications < ActiveRecord::Migration[7.0]
  def change
    add_column(
      :crime_applications,
      :return_reason,
      :virtual,
      as: "(return_details->>'reason')",
      type: :string,
      stored: true
    )

    add_index :crime_applications, :return_reason
  end
end
