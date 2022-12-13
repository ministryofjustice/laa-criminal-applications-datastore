module Datastore
  module V2
    class Searches < Base
      version 'v2', using: :path

      resource :searches do
        desc 'Search the Datastore.'
        params do
          optional :search, type: JSON, desc: 'Search JSON.' do
            optional :application_ids, type: Array
            optional :search_text, type: String
          end
          optional :pagination, type: JSON, desc: 'Pagination JSON.' do
            use :pagination
          end
        end

        post do
          search = Operations::Search.new(**declared(params).symbolize_keys).call
          present :pagination, search, with: Datastore::Entities::Pagination
          present :records, search, with: Datastore::Entities::SearchResult
        end
      end
    end
  end
end
