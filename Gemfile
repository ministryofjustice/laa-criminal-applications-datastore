source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').chomp

gem 'pg', '~> 1.4'
gem 'puma'
gem 'rails', '~> 7.0.4'

gem 'grape', '~> 1.7.0'
gem 'grape-entity', '~> 0.10.2'
gem 'kaminari-activerecord'

# Datastore API authentication
gem 'moj-simple-jwt-auth', '0.0.1'

# SNS/SQS messaging
gem 'aws-sdk-sns'
gem 'aws-sdk-sqs'

# NOTE: we can probably remove this gem in favor of a simpler
# approach to messaging. Can be done as a separate PR.
gem 'shoryuken'

gem 'laa-criminal-legal-aid-schemas',
    github: 'ministryofjustice/laa-criminal-legal-aid-schemas'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails'
  gem 'pry'
  gem 'rspec-rails'
end

group :test do
  gem 'brakeman'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'simplecov', require: false
  gem 'webmock'
end
