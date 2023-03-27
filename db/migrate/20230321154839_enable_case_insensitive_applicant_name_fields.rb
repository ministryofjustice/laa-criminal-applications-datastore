class EnableCaseInsensitiveApplicantNameFields < ActiveRecord::Migration[7.0]
  def up
    enable_extension 'citext'
    change_column :crime_applications, :applicant_first_name, :citext
    change_column :crime_applications, :applicant_last_name, :citext
  end

  def down
    change_column :crime_applications, :applicant_first_name, :string
    change_column :crime_applications, :applicant_last_name, :string
    disable_extension 'citext'
  end
end
