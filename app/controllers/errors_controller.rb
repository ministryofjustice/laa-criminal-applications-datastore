class ErrorsController < ApplicationController
  def not_found
    respond_with_status(:not_found)
  end

  private

  def respond_with_status(status)
    head status
  end
end
