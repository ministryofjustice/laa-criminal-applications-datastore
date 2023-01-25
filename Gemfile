source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').chomp

gem 'pg', '~> 1.4'
gem 'puma'
gem 'rails', '~> 7.0.4'

gem 'grape', '~> 1.6.2'
gem 'grape-entity', '~> 0.10.2'
gem 'kaminari-activerecord'

# Temporarily until 2.8.1 is released
# https://github.com/mikel/mail/issues/1541
gem 'mail', '< 2.8.0'

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
end
