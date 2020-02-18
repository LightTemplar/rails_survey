# frozen_string_literal: true

require_relative 'boot'

require 'csv'
require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'action_cable/engine'
require 'sprockets/railtie'
require 'rails/test_unit/railtie'

Bundler.require(*Rails.groups)

module RailsSurvey
  class Application < Rails::Application
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins 'localhost:3001', '127.0.0.1:3001'
        resource '*', headers: :any,
                      expose: %w[access-token expiry token-type uid client],
                      methods: %i[get post put delete options]
      end
    end

    config.time_zone = 'Eastern Time (US & Canada)'

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
    config.assets.precompile += %w[active_admin.js active_admin.scss]

    config.api_only = true

    config.middleware.use Rack::MethodOverride
    config.middleware.use ActionDispatch::Flash
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore
  end
end
