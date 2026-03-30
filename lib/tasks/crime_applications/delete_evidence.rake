namespace :crime_applications do
  desc 'Permanently delete evidence from S3 for a given application and create deletion entries'
  task :delete_evidence, [:application_id, :s3_object_keys, :reason] => :environment do |_task, args|
    log = ->(message) { puts("[crime_applications:delete_evidence] #{message}") }
    dry_run = ActiveModel::Type::Boolean.new.cast(ENV["DRY_RUN"])
    crime_application = CrimeApplication.find(args[:application_id])
    s3_object_keys = args[:s3_object_keys].to_s.split(' ')
    raise ArgumentError, "No S3 object keys provided" if s3_object_keys.blank?
    reason = Types::DeletionReason[args[:reason]]

    existing_supporting_evidence = crime_application.submitted_application['supporting_evidence']
    raise StandardError, "No evidence found for application #{crime_application.id}" if existing_supporting_evidence.blank?
    unless s3_object_keys.all? { |object_key| existing_supporting_evidence.pluck('s3_object_key').include?(object_key) }
      raise StandardError, "At least one provided S3 key is not present on application #{crime_application.id}"
    end

    remaining_evidence_ids = existing_supporting_evidence.pluck('s3_object_key').reject { |key| key.in?(s3_object_keys) }

    if dry_run
      log.call("Remaining evidence expected after successful deletion: #{remaining_evidence_ids.inspect}")
    else
      log.call("Deleting S3 objects #{s3_object_keys.inspect} linked to application #{crime_application.id}...")
      correlation_id = SecureRandom.uuid
      successful_deletions = []
      failed_deletions = []
      s3_object_keys.each do |object_key|
        begin
          Operations::Documents::Delete.new(object_key:).call
          successful_deletions << object_key
        rescue Errors::DocumentUploadError => e
          log.call("Exception when deleting #{object_key} - #{e.message}")
          failed_deletions << object_key
        end
      end
      log.call("Successful deletions - #{successful_deletions.inspect}")
      log.call("Failed deletions - #{failed_deletions.inspect}")

      successful_deletions.each do |deletion|
        DeletionEntry.create!(
          record_id: deletion,
          record_type: Types::RecordType['document'],
          business_reference: crime_application.reference,
          deleted_by: 'system_manual',
          deleted_from: Types::RecordSource['amazon_s3'],
          reason: reason,
          correlation_id: correlation_id
        )
      end
    end
    log.call('Done')
  end
end
