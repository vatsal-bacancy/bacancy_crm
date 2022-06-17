source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Rails
gem 'rails', '5.2.4.2'

# Use postgresql as the database adapter for ActiveRecord
gem 'pg'

# Use Puma as the app server
gem 'puma', '~> 3.7'

# Rails UI plugins
gem 'sass-rails', '~> 5.0' # SCSS for stylesheets
gem 'uglifier', '>= 1.3.0' # Use Uglifier as compressor for JavaScript assets
gem 'coffee-rails', '~> 4.2' # Use CoffeeScript for .coffee assets and views
gem 'turbolinks', '~> 5' # Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'jbuilder', '~> 2.5' # Build JSON APIs with ease
gem "js-routes" # Rails routing from JS

# For Datatable responses
# Fork's features:
#   1. Allows us to pass custom table alias while using `joins of same table twice`
#   2. Fixes issue with numeric string in global search
gem 'ajax-datatables-rails', git: 'https://github.com/vivekmiyani/ajax-datatables-rails.git'

# Application configuration
gem "figaro"

# Authentication and authorization
gem 'devise'
gem 'cancancan'
gem 'rolify'

# File upload
gem 'carrierwave-aws'
gem 'carrierwave', '~> 1.0'
gem 'fog-aws'
gem 'aws-sdk-rails'

gem 'mini_magick'

# Soft deletion for ActiveRecord
gem "audited", "~> 4.7"

# ActiveRecord history with association
gem 'time_machine', '0.1', git: 'https://github.com/vivekmiyani/time_machine.git'

# ActiveRecord tree structure
gem 'ancestry', '~> 3.2'

# Exception notifier
gem 'exception_notification'

# Google maps
gem 'gmaps4rails'
gem 'geokit-rails'

# OAuth integration
gem 'oauth2'

# mail box integration
gem 'google-api-client', require: ['google/apis/gmail_v1', 'google/apis/calendar_v3']
gem 'microsoft_graph', git: 'https://github.com/vivekmiyani/msgraph-sdk-ruby.git'

# SMS integration
gem 'twilio-ruby', '~> 5.41.0'

# IP to Location
gem 'geocoder', '~> 1.6'

# Payments
gem 'authorizenet'

# Shipments
gem 'fedex', git: 'https://github.com/vivekmiyani/fedex.git'

# Cron jobs and background worker
gem 'whenever', require: false
gem 'sidekiq'
gem 'sidekiq-cron'
gem "daemons"

# Date format
gem 'american_date'

# PDF generation
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'

# Template generation
gem 'mustache', '~> 1.0'

# Jquery plugins
gem 'select2-rails', '~> 4.0', '>= 4.0.3'
gem 'croppie_rails'
gem 'ckeditor'
gem 'cocoon'
gem 'dropzonejs-rails'

# Chart
gem 'chartkick'

group :development, :test do
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
  gem 'pry-rails'
  gem 'pry-nav'
end
group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'capistrano',         require: false
  gem 'capistrano-rvm',     require: false
  gem 'capistrano-rails',   require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-passenger',   require: false
end
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
