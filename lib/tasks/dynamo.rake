namespace :dynamo do
  desc 'Creates DynamoDB tables, one for each of your Dynamoid models - does not modify pre-existing tables'
  task create_tables: :environment do
    # we use the existing dynamoid task for this
    Rake::Task['dynamoid:create_tables'].invoke
  end

  desc 'Drop all existing tables'
  task drop_tables: :environment do
    raise RuntimeError if Rails.env.production?

    Dynamoid.adapter.list_tables.each do |table|
      # Only delete tables in our namespace
      if table =~ /^#{Dynamoid::Config.namespace}/
        Dynamoid.adapter.delete_table(table)
      end
    end

    Dynamoid.adapter.tables.clear
  end

  desc 'List existing tables'
  task list_tables: :environment do
    puts Dynamoid.adapter.list_tables
  end

  desc 'Setup indexes'
  task setup_indexes: :environment do
    puts 'Setting up indexes...'

    Rake::Task['indexes:StatusSubmittedAtIndex'].invoke

    puts 'Finished setup of indexes.'
  end
end
