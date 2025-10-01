class DeletableEntity < ApplicationRecord
  scope :expired, lambda {
    where(review_deletion_at: ..Time.zone.now)
  }
end
