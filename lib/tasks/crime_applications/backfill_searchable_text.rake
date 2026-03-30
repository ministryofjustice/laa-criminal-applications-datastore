namespace :crime_applications do
  desc 'Backfill the searchable_text column for all crime applications'
  task backfill_searchable_text: :environment do
    log = ->(message) { puts("[crime_applications:backfill_searchable_text] #{message}") }
    batch_size = ENV.fetch('BATCH_SIZE', 500).to_i
    total = CrimeApplication.where(hard_deleted_at: nil, searchable_text: nil).count
    updated = 0

    log.call("Backfilling searchable_text for #{total} crime application(s) in batches of #{batch_size}...")

    CrimeApplication.where(hard_deleted_at: nil, searchable_text: nil).in_batches(of: batch_size) do |batch|
      # rubocop:disable Rails/SkipsModelValidations
      batch.update_all(<<~SQL.squish)
        searchable_text = (
          to_tsvector('english', COALESCE(submitted_application #>> '{client_details,applicant,first_name}', ''))
          || to_tsvector('english', COALESCE(submitted_application #>> '{client_details,applicant,last_name}', ''))
          || to_tsvector('english', COALESCE(submitted_application ->> 'reference', ''))
          || COALESCE(to_tsvector('simple', maat_id::text), ''::tsvector)
          || COALESCE(
              (SELECT to_tsvector('simple', string_agg(d.maat_id::text, ' '))
               FROM decisions d WHERE d.crime_application_id = crime_applications.id
                 AND d.maat_id IS NOT NULL),
              ''::tsvector
            )
        )
      SQL
      # rubocop:enable Rails/SkipsModelValidations

      updated += batch.count
      log.call("Updated #{updated}/#{total}")
    end

    log.call('Done')
  end
end
