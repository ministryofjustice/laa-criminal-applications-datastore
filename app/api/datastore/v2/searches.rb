module Datastore
  module V2
    class Searches < Base
      version 'v2', using: :path

      resource :searches do
        desc 'Search the Datastore.'
        params do
          optional :search, type: JSON, desc: 'Search JSON.' do
            optional :application_id_in, type: Array
            optional :application_id_not_in, type: Array
            optional :search_text, type: String
            optional :applicant_date_of_birth, type: Date

            optional(
              :status,
              type: Array[String],
              values: Types::APPLICATION_STATUSES
            )

            optional(
              :review_status,
              type: Array[String],
              values: Types::REVIEW_APPLICATION_STATUSES
            )

            optional :submitted_after, type: DateTime
            optional :submitted_before, type: DateTime
          end

          optional :pagination, type: JSON, desc: 'Pagination JSON.' do
            use :pagination
          end
        end

        post do
          search_params = declared(params).symbolize_keys
          search = Operations::Search.new(**search_params).call
          present :pagination, search, with: Datastore::Entities::Pagination
          present :records, search, with: Datastore::Entities::SearchResult
        end
      end
    end
  end
end
