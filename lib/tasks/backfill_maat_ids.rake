desc 'Backfill MAAT IDs from a CSV export'
task :backfill_maat_ids, [:csv_path] => :environment do |task, args|
  require 'csv'

  csv_path = args[:csv_path]

  mapped_usns = []
  CSV.foreach(csv_path, headers: true) do |row|
    crime_application = CrimeApplication.find_by(reference: row['USN'].to_i)
    if crime_application.present?
      crime_application.update!(maat_id: row['MAAT_ID'].to_i)
      mapped_usns << crime_application.reference
    end
  end

  CSV.open('/tmp/mapped_usns.csv', 'w', write_headers: true, headers: ['USN']) do |csv|
    mapped_usns.each { |usn| csv << [usn.to_s] }
  end

  puts 'Done'
end
