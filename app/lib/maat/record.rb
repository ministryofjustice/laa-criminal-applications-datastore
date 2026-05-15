module MAAT
  class Record < Dry::Struct
    transform_keys(&:to_sym)

    attribute? :usn, Types::ApplicationReference.optional
    attribute? :maat_ref, Types::Integer
    attribute? :case_id, Types::String
    attribute? :case_type, Types::String
    attribute? :ioj_result, Types::String.optional
    attribute? :ioj_reason, Types::String.optional
    attribute? :ioj_assessor_name, Types::String.optional
    attribute? :app_created_date, Types::JSON::DateTime.optional
    attribute? :means_result, Types::String.optional
    attribute? :means_assessor_name, Types::String.optional
    attribute? :date_means_created, Types::JSON::DateTime.optional
    attribute? :funding_decision, Types::String.optional
    attribute? :cc_rep_decision, Types::String.optional
    attribute? :ioj_appeal_result, Types::String.optional
    attribute? :ioj_appeal_assessor_name, Types::String.optional
    attribute? :ioj_appeal_date, Types::JSON::DateTime.optional
    attribute? :passport_result, Types::String.optional
    attribute? :passport_assessor_name, Types::String.optional
    attribute? :date_passport_created, Types::JSON::DateTime.optional
    attribute? :passport_review_type, Types::String.optional
    attribute? :means_review_type, Types::String.optional
    attribute? :passport_work_reason, Types::String.optional
    attribute? :means_work_reason, Types::String.optional
  end
end
