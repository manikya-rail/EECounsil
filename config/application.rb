require_relative 'boot'

require 'rails/all'
require "active_model_serializers"
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

APP_CONFIG = YAML.load_file('config/application.yml')[Rails.env]

module Appointment
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2
    config.active_job.queue_adapter = :delayed_job
    # Settings in config/environments/* take precedence over those specified here
	
	config.eager_load_paths << Rails.root.join('lib/klasses')
    config.autoload_paths << Rails.root.join('lib/klasses')
    
config.eager_load_paths << Rails.root.join('lib')
config.autoload_paths << Rails.root.join('lib')
        # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end

