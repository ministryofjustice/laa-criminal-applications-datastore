module Datastore
  module V2
    class Applications < Base
      version 'v2', using: :path

      resource :applications do
        desc 'Create an application.'
        params do
          requires :application, type: JSON, desc: 'Application JSON payload.'
        end
        post do
          Operations::CreateApplication.new(
            payload: params[:application]
          ).call
        end
      end
    end
  end
end
