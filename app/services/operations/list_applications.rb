module Operations
  class ListApplications
    attr_reader :limit, :sort, :page_token,
                :status

    INDEX_DIRECTIONS = [
      SCAN_DIRECTION_FORWARD  = 'asc'.freeze,
      SCAN_DIRECTION_BACKWARD = 'desc'.freeze,
    ].freeze

    def initialize(status:, **pagination_opts)
      @status = status

      @limit = pagination_opts['limit']
      @sort = pagination_opts['sort']
      @page_token = pagination_opts['page_token']
    end

    def call
      records, metadata = query
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

    def query
      CrimeApplication.where(status:)
    end

    def total
      query.count
    end

    def pagination_details(metadata)
      {
        limit: limit,
        total: total,
        sort: sort,
        next_page_token: next_page(metadata),
      }
    end

    def scan_index_forward
      sort.eql?(SCAN_DIRECTION_FORWARD)
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
