namespace :applications do
  # NOTE: this task can be deleted once it has been run
  desc 'Reassign applications to new office code'
  task reassign_office: :environment do
    reassign_counter = 0
    new_office_code = '1K022G'.freeze

    puts "Reassigning applications to new office code #{new_office_code}"

    CrimeApplication.find_each(batch_size: 30) do |record|
      details = record.application.dig('provider_details')

      if details['office_code'] != new_office_code
        details['office_code'] = new_office_code
        record.save(touch: false)
        reassign_counter += 1
      end
    end

    puts "#{reassign_counter} applications have been reassigned"
  end
end
