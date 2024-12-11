module Redacting
  class MetadataWrapper < SimpleDelegator
    def metadata
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
        application_type:,
      }.stringify_keys
    end

    private

    def return_reason
      return_details.try(:[], 'reason')
    end
  end
end
