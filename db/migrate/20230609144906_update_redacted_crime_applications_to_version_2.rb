class UpdateRedactedCrimeApplicationsToVersion2 < ActiveRecord::Migration[7.0]
  def change
    replace_view :redacted_crime_applications, version: 2, revert_to_version: 1
  end
end
