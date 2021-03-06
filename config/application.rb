require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ShortTest
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    config.active_job.queue_adapter = :resque

    # Add lib to LOAD_PATHS
    LOAD_PATHS = %W[
      #{config.root}/lib
    ].freeze

    # Add paths to autoload
    config.autoload_paths += LOAD_PATHS
    config.eager_load_paths += LOAD_PATHS

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
