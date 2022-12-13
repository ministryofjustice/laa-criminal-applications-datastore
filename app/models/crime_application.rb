class CrimeApplication < ApplicationRecord
  attr_readonly :application, :submitted_at, :id

  STATUSES = %w[submitted returned].freeze

  before_validation :set_id, on: :create

  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :by_status, ->(status) { where(status:) }

  private

  def set_id
    return unless id.nil?
    return unless application

    self.id = application.fetch('id')
  end
end
