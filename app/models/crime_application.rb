class CrimeApplication < ApplicationRecord
  before_validation :set_id, on: :create

  private

  def set_id
    return unless id.nil?
    return unless application

    self.id = application.fetch('id')
  end
end
