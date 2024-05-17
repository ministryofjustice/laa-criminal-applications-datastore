source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').chomp

gem 'pg', '~> 1.4'
gem 'puma'
gem 'rails', '~> 7.0.8', '>= 7.0.8.1'

gem 'grape', '~> 1.8.0'
gem 'grape-entity', '~> 0.10.2'
gem 'grape_logging'
gem 'kaminari-activerecord'

# Monitoring
gem 'prometheus_exporter'

# Exceptions notifications
gem 'sentry-rails', '>= 5.16.1'
gem 'sentry-ruby'
gem 'stackprof'

# Datastore API authentication
gem 'moj-simple-jwt-auth', '0.1.0'

# AWS services
gem 'aws-sdk-s3'
gem 'aws-sdk-sns'

gem 'laa-criminal-legal-aid-schemas',
    github: 'ministryofjustice/laa-criminal-legal-aid-schemas', tag: 'v1.0.75'

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
  gem 'rubocop', '>= 1.62.1', require: false
  gem 'rubocop-performance', '>= 1.21.0', require: false
  gem 'rubocop-rails', '>= 2.24.1', require: false
  gem 'rubocop-rspec', '>= 2.28.0', require: false
  gem 'simplecov', require: false
  gem 'webmock'
end
