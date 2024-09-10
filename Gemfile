source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').chomp

gem 'pg', '~> 1.5.6'
gem 'puma'
gem 'rails', '~> 7.1.3'

gem 'grape', '~> 2.1.3'
gem 'grape-entity', '~> 1.0.1'
gem 'grape_logging'
gem 'kaminari-activerecord'

# Monitoring
gem 'prometheus_exporter'

# Exceptions notifications
gem 'sentry-rails', '>= 5.18.1'
gem 'sentry-ruby'
gem 'stackprof'

# Datastore API authentication
gem 'moj-simple-jwt-auth', '0.1.0'

# AWS services
gem 'aws-sdk-s3'
gem 'aws-sdk-sns'

gem 'laa-criminal-legal-aid-schemas',
    github: 'ministryofjustice/laa-criminal-legal-aid-schemas',
    ref: 'bb3ed9ddb13cd559ae125a9a33739b80a0ede401'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'byebug'
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  # Issue with freezing ENV with dotenv-rails v3 https://github.com/bkeepers/dotenv/issues/482
  gem 'dotenv-rails', '~> 2.8.1'
  gem 'pry'
  gem 'rspec-rails', '>= 6.1.1'
end

group :test do
  gem 'brakeman'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'simplecov', require: false
  gem 'webmock', '>= 3.23.1'
end
