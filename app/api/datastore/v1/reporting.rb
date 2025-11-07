module Datastore
  module V1
    class Reporting < Base
      version 'v1', using: :path

      resource :reporting do
        resource :volumes_by_office do
          route_setting :authorised_consumers, %w[crime-review]

          params do
            requires(
              :period,
              type: String,
              year_month_format: true,
              desc: "Month in '%Y-%B' format (e.g. '2025-November')"
            )

            optional(
              :application_types,
              type: [String],
              default: Types::ApplicationType.values - [Types::ApplicationType['post_submission_evidence']],
              values: Types::ApplicationType.values,
              desc: "Application types to be counted. Defaults to all types except 'Post Submission Evidence'."
            )
          end

          get 'monthly/:period' do
            ::Reporting::VolumesByOfficeReport.new(params)
          end
        end
      end
    end
  end
end
