class AddReviewStatusReviewReasonAndTimestampsToCrimeApplications < ActiveRecord::Migration[7.0]
  def change
    add_column :crime_applications, :review_status, :string
    add_column :crime_applications, :review_received_at, :timestamp
    rename_column :crime_applications, :completed_at, :review_completed_at
    add_column :crime_applications, :return_reason, :jsonb, default: {}

    add_index(
      :crime_applications,
      [:review_status, :review_completed_at],
      order: { review_completed_at: :desc},
      name: 'index_crime_apps_on_review_status_and_review_completed_at'
    )
  end
end
