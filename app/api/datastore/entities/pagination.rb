module Datastore
  module Entities
    class Pagination < Grape::Entity
      present_collection true

      expose :total_pages
      expose :current_page
      expose :total_count

      private

      delegate :total_pages, :current_page, :total_count, to: :collection

      def collection
        @collection ||= object.fetch(:items)
      end
    end
  end
end
