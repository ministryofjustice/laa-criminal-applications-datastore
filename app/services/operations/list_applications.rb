module Operations
  class ListApplications
    attr_reader :limit, :page_token, :direction,
                :status

    INDEX_DIRECTIONS = [
      SCAN_DIRECTION_FORWARD  = 'forward'.freeze,
      SCAN_DIRECTION_BACKWARD = 'backward'.freeze,
    ].freeze

    def initialize(limit:, page_token:, direction:, status:)
      @limit = limit
      @page_token = page_token
      @direction = direction
      @status = status
    end

    # NOTE: pagination is not working as expected, probably
    # we need to set the indexes correctly first
    def call
      records, metadata = CrimeApplication
                          .where(status:)
                          .scan_index_forward(scan_index_forward)
                          .record_limit(limit)
                          .start(start_page)
                          .find_by_pages.first

      {
        pagination: pagination_details(metadata),
        records: records,
      }
    end

    private

    def pagination_details(metadata)
      {
        limit: limit,
        direction: direction,
        next_page_token: next_page(metadata),
      }
    end

    def scan_index_forward
      direction.eql?(SCAN_DIRECTION_FORWARD)
    end

    def start_page
      return unless page_token

      JSON.parse(Base64.strict_decode64(page_token))
    end

    def next_page(metadata)
      return unless (last_evaluated_key = metadata[:last_evaluated_key].presence)

      Base64.strict_encode64(last_evaluated_key.to_json)
    end
  end
end
