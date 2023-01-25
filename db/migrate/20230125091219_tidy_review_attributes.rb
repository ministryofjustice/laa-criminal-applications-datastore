class TidyReviewAttributes < ActiveRecord::Migration[7.0]
  def change
    change_table :crime_applications do |t|
      t.remove_index ["status", "review_completed_at"]
      t.remove_index ["review_status", "review_completed_at"]
      t.rename :review_completed_at, :reviewed_at
      t.remove :review_received_at
      t.remove :return_reason
    end

    add_index(:crime_applications, [:status, :reviewed_at], order: { reviewed_at: :desc} )
  end
end
