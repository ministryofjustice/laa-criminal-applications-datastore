module Reporting
  class VolumesByOfficeReport
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :period, :string
    attribute :application_types, array: true, default: -> { [] }

    def data
      CrimeApplication.where(
        submitted_at: range,
        application_type: application_types
      ).group(:office_code).count
    end

    def as_json(_options = {})
      { data: }
    end

    def range
      date.all_month
    end

    def date
      Date.strptime(period, YearMonthFormat::FORMAT).in_time_zone('London')
    end
  end
end
