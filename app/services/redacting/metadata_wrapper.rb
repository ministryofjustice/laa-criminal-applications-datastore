module Redacting
  class MetadataWrapper < SimpleDelegator
    def metadata # rubocop:disable Metrics/MethodLength
      {
        status:,
        returned_at:,
        reviewed_at:,
        review_status:,
        offence_class:,
        return_reason:,
        created_at:,
        submitted_at:,
        office_code:,
        work_stream:,
        application_type:,
      }.stringify_keys
    end

    private

    def return_reason
      return_details.try(:[], 'reason')
    end
  end
end
