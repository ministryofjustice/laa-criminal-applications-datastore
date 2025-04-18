source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').chomp

gem 'pg', '~> 1.5.6'
gem 'puma'

gem 'grape'
gem 'grape-entity'
gem 'grape_logging'
gem 'grape-swagger'
gem 'kaminari-activerecord'
gem 'rails', '~> 7.2'

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
    tag: 'v1.7.1'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'byebug'
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  # Issue with freezing ENV with dotenv-rails v3 https://github.com/bkeepers/dotenv/issues/482
  gem 'dotenv-rails', '~> 2.8.1'
  gem 'pry'
  gem 'rspec-rails', '>= 7.1.1'
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

gem 'ostruct', '~> 0.6.1'

gem 'benchmark', '~> 0.4.0'
