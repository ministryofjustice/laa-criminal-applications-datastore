module Datastore
  module Entities
    class Pagination < Grape::Entity
      present_collection true

      expose :limit_value
      expose :total_pages
      expose :current_page
      expose :next_page
      expose :prev_page
      expose :total_count

      private

      delegate :limit_value, :total_pages, :current_page, :next_page, :prev_page, :total_count, to: :collection

      def collection
        @collection ||= object.fetch(:items)
      end
    end
  end
end
