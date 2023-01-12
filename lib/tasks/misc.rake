namespace :misc do
  # NOTE: this task can be deleted once it has been run
  desc 'Update offence dates to the new format'
  task update_offences: :environment do
    puts 'Migrating offence dates...'

    CrimeApplication.find_each(batch_size: 30) do |record|
      offences = record.application.dig('case_details', 'offences')

      offences.each do |offence|
        dates = offence.dig('dates')

        dates.each.with_index do |date, index|
          next if date.is_a?(Hash) # in case it has already the new format

          puts "---> Updating app #{record.application['reference']} offence #{offence['name']} date #{date}..."

          dates[index] = { date_from: date, date_to: nil }.as_json
        end
      end

      record.save(touch: false)
    end

    puts 'All existing offence dates migrated to the new format.'
  end

  # NOTE: this task can be deleted once it has been run
  desc 'Delete orphan applications'
  task delete_orphans: :environment do
    puts 'Deleting applications without provider details...'

    uuids_to_remove = []

    CrimeApplication.find_each(batch_size: 30) do |record|
      details = record.application.dig('provider_details')

      if details['office_code'].blank? || details['legal_rep_first_name'].blank?
        puts "---> Application #{record.application['reference']} will be deleted ..."
        uuids_to_remove << record.id
      end
    end

    CrimeApplication.destroy_by(id: uuids_to_remove)

    puts 'All applications without provider details have been deleted'
  end
end
