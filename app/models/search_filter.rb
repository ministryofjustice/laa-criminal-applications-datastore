class SearchFilter
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :application_id_in, array: true, default: -> { [] }
  attribute :application_id_not_in, array: true, default: -> { [] }
  attribute :status, array: true, default: -> { [] }
  attribute :review_status, array: true, default: -> { [] }
  attribute :applicant_date_of_birth, :date
  attribute :search_text, :string
  attribute :submitted_after, :datetime
  attribute :submitted_before, :datetime

  def active_filters
    attributes.compact_blank.keys
  end

  def apply_to_scope(scope)
    active_filters.each do |f|
      scope = send("filter_#{f}", scope)
    end

    scope
  end

  private

  def filter_applicant_date_of_birth(scope)
    scope.where(
      "application->'client_details'->'applicant'->>'date_of_birth' = ?::text",
      applicant_date_of_birth
    )
  end

  def filter_submitted_after(scope)
    scope.where('submitted_at >  ?', submitted_after)
  end

  def filter_submitted_before(scope)
    scope.where('submitted_at <  ?', submitted_before)
  end

  def filter_application_id_in(scope)
    scope.where(id: application_id_in)
  end

  def filter_application_id_not_in(scope)
    scope.where.not(id: application_id_not_in)
  end

  def filter_status(scope)
    scope.where(status:)
  end

  def filter_review_status(scope)
    scope.where(review_status:)
  end

  def filter_search_text(scope)
    query_text = search_text.split.join('&')
    scope.where('searchable_text @@ to_tsquery(?)', query_text)
  end
end
