module Datastore
  module Entities
    module V1
      class BaseApplicationEntity < Grape::Entity
        expose :id
        expose :schema_version
        expose :reference
        expose :application_type
        expose :submitted_at
        expose :status
        expose :review_status
        expose :reviewed_at
        expose :parent_id
        expose :created_at
        expose :work_stream
        expose :soft_deleted_at, expose_nil: false

        # Generates private methods that delegate to submitted_value
        def self.submitted_delegates(*names)
          names.each do |name|
            define_method(name) { submitted_value(name.to_s) }
          end
        end

        # Generates private methods that delegate to submitted_value with a default
        def self.submitted_delegates_with_default(mappings)
          mappings.each do |name, default|
            define_method(name) { submitted_value(name.to_s) || default }
          end
        end

        submitted_delegates :additional_information, :application_type, :client_details,
                            :date_stamp, :date_stamp_context, :created_at, :id,
                            :ioj_passport, :interests_of_justice, :means_passport,
                            :parent_id, :provider_details, :reference, :schema_version,
                            :pre_cifc_reference_number, :pre_cifc_maat_id,
                            :pre_cifc_usn, :pre_cifc_reason

        submitted_delegates_with_default means_details: {}, supporting_evidence: [],
                                         evidence_details: {}

        private_class_method :submitted_delegates, :submitted_delegates_with_default

        private

        def is_means_tested # rubocop:disable Naming/PredicateName
          submitted_value('is_means_tested')
        end

        def case_details
          case_details = submitted_value('case_details') || {}
          case_details['offence_class'] = object.offence_class
          case_details
        end

        def submitted_at
          return object.submitted_at if object.soft_deleted_at.blank?

          object.submitted_at.in_time_zone('London').at_midnight
        end

        def submitted_value(name)
          object.submitted_application&.dig(name)
        end
      end
    end
  end
end
