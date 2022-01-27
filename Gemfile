source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.1'
# Use postgresql as the database for Active Record
# gem 'sqlite3'
gem 'pg'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2', group: :development

# gem 'rb-readline', group: :development
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
gem 'sidekiq', '~> 5.2', '>= 5.2.7'
gem 'sidekiq-cron'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  #gem 'rb-readline'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

#devise gem
gem 'devise'

#rolify for assigning roles to user
gem "rolify"
gem "jquery-rails"
gem "cocoon"
gem 'ckeditor', '4.2.4'
gem 'devise_token_auth'
gem 'rack-cors', :require => 'rack/cors'


#gems for adding datatalbles
gem 'ajax-datatables-rails'
gem 'jquery-datatables'

#datepicker gem selecting gem
gem 'bootstrap-datepicker-rails'

#cancan gem for authorization
gem 'cancancan', '~> 2.0'

#to select the country
#gem 'country_select', '~> 4.0'
gem 'city-state', '~> 0.0.13'
#Serializer for API's
gem 'active_model_serializers', '0.9.3'

#ImageUplodingGem
gem 'carrierwave', '~> 1.0'
#gem 'carrierwave-video'
#ToUploadImagesOnAWS
gem 'fog'
gem 'streamio-ffmpeg'
#select-2 gem for selecting multiple things
gem "select2-rails"

#backend jobs run
gem 'daemons'
#To_run_process_in_background
gem 'delayed_job_active_record'

#to run certain task regularly
gem 'whenever', require: false

#ActiveMerchant for handling multiple payment gatways
gem 'activemerchant'

gem 'fullcalendar-rails'
gem 'momentjs-rails'

#payment gateway (Stripe)
gem 'stripe'

#Act as state machine gem
gem "aasm"

#Google_map integration
gem 'gmaps4rails'

gem 'twilio-ruby'

gem 'geocoder'
#get the timezone through latitude and longitude
gem 'timezone', '~> 1.0'

gem 'pry'

