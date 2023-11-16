require_relative 'boot'

require "csv"
require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RailsSurvey
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.environment = "development"
    config.load_defaults 5.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.before_configuration do
      env_file = File.join(Rails.root, 'config', 'local_env.yml')
      if File.exist?(env_file) && !File.zero?(env_file)
        YAML.safe_load(File.open(env_file)).each do |key, value|
          value = value.to_s if value.is_a?(Integer)
          ENV[key.to_s] = value
        end
      end
    end

    I18n.enforce_available_locales = false
    config.cache_store = :redis_store, "#{ENV['REDIS_CACHE_URL']}/cache", { expires_in: 6.hours }
    config.autoload_paths += Dir[Rails.root.join('app', 'scorers', '{*/}')]
    config.assets.precompile += %w[active_admin.js active_admin.css.scss]
    config.time_zone = 'Eastern Time (US & Canada)'

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins ENV.fetch('ORIGIN_1', '127.0.0.1'), ENV.fetch('ORIGIN_2', 'localhost')
        # origins ENV['ORIGIN_1'], ENV['ORIGIN_2']
        resource '*', headers: :any,
                      expose: %w[access-token expiry token-type uid client],
                      methods: %i[get post put delete options]
      end
    end
    config.middleware.use Rack::MethodOverride
    config.middleware.use ActionDispatch::Flash
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore
  end
end
