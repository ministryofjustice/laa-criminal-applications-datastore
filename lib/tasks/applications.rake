namespace :applications do
  # NOTE: this task can be deleted once it has been run
  desc 'Add new means_passport attribute to existing applications'
  task add_means_passport: :environment do
    puts "Adding new `means_passport` attribute to existing applications"

    means_attribute = { means_passport: ['on_benefit_check'] }.to_json

    CrimeApplication.update_all(
      "application = application || '#{means_attribute}'::jsonb"
    )

    puts "Done"
  end
end
