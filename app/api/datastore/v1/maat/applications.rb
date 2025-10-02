module Datastore
  module V1
    module MAAT
      class Applications < Base
        version 'v1', using: :path

        route_setting :authorised_consumers, %w[maat-adapter maat-adapter-dev maat-adapter-uat]

        resource :applications do
          desc 'Return an application by USN.'
          params do
            requires :usn, type: Integer, desc: 'Application USN.'
          end

          route_param :usn do
            get do
              Operations::MAAT::GetApplication.new(reference: params[:usn]).call
            end
          end

          desc 'Create a MaatRecordCreated event for an application.'
          params do
            requires :entity_id, type: String, desc: 'Application UUID.'
            requires :entity_type, type: String, values: Types::APPLICATION_TYPES, desc: 'Application type.'
            requires :business_reference, type: String, desc: 'Application reference number.'
            requires :maat_id, type: String, desc: 'Id of the MAAT record.'
          end
          post 'maat_record_created' do
            Operations::MAATRecordCreated.new(**declared(params).symbolize_keys).call
          end
        end
      end
    end
  end
end
