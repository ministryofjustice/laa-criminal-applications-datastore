class StatusController < ApplicationController
  BUILD_ARGS = {
    build_date: ENV.fetch('APP_BUILD_DATE', nil),
    build_tag:  ENV.fetch('APP_BUILD_TAG',  nil),
    commit_id:  ENV.fetch('APP_GIT_COMMIT', nil),
  }.freeze

  def ping
    render json: BUILD_ARGS
  end
end
