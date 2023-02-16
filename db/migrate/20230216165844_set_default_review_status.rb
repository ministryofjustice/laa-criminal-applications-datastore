class SetDefaultReviewStatus < ActiveRecord::Migration[7.0]
  def change
    change_column_null :crime_applications, :review_status, false, Types::ReviewApplicationStatus['application_received']
    change_column_default :crime_applications, :review_status, from: nil, to: Types::ReviewApplicationStatus['application_received']
  end
end
