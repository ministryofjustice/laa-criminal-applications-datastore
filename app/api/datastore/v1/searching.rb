module Datastore
  module V1
    class Searching < Base
      version 'v1', using: :path

      route_setting :authorised_consumers, %w[crime-review]

      resource :searches do
        desc 'Search the Datastore.'
        params do
          optional :search, type: JSON, desc: 'Search JSON.' do
            optional :application_id_in, type: Array
            optional :application_id_not_in, type: Array
            optional :search_text, type: String
            optional :applicant_date_of_birth, type: Date

            optional(:status, type: [String], values: Types::APPLICATION_STATUSES)
            optional(:review_status, type: [String], values: Types::REVIEW_APPLICATION_STATUSES)
            optional(:work_stream, type: [String], values: Types::WORK_STREAM_TYPES)

            optional :submitted_after, type: DateTime
            optional :submitted_before, type: DateTime

            optional :reviewed_after, type: DateTime
            optional :reviewed_before, type: DateTime
          end

          optional :sorting, type: JSON, desc: 'Sorting JSON.', default: Sorting.new.attributes do
            use :sorting
          end

          optional :pagination, type: JSON, desc: 'Pagination JSON.' do
            use :pagination
          end
        end

        post do
          search_params = declared(params).symbolize_keys
          search = Operations::Search.new(**search_params)
          records = search.call

          present :pagination, records, with: Datastore::Entities::V1::Pagination
          present :sorting, search.sorting, with: Datastore::Entities::V1::Sorting
          present :records, records, with: Datastore::Entities::V1::SearchResult
        end
      end
    end
  end
end
