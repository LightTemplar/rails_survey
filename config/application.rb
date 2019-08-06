# frozen_string_literal: true

require File.expand_path('boot', __dir__)

require 'csv'
require 'rails/all'

Bundler.require(:default, Rails.env)

module RailsSurvey
  class Application < Rails::Application
    config.middleware.insert_before 0, 'Rack::Cors' do
      allow do
        origins 'localhost:3001', '127.0.0.1:3001'
        resource '*', headers: :any,
                      expose: ['access-token', 'expiry', 'token-type', 'uid', 'client'],
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

    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')
    config.assets.paths << Rails.root.join('vendor', 'assets', 'images')
    config.assets.paths << Rails.root.join('vendor', 'assets', 'lib')
    config.assets.paths << Rails.root.join('vendor', 'assets', 'fonts')
    config.assets.paths << Rails.root.join('vendor', 'assets', 'templates')
    I18n.enforce_available_locales = false
    config.assets.initialize_on_precompile = false
    config.assets.precompile += %w[active_admin.js active_admin.css.scss]
    config.wiki_path = 'wiki.git'
    config.cache_store = :redis_store, "#{ENV['REDIS_CACHE_URL']}/cache", { expires_in: 6.hours }
    config.autoload_paths += Dir[Rails.root.join('app', 'scorers', '{*/}')]
    config.action_controller.include_all_helpers = false
    config.active_record.raise_in_transactional_callbacks = true
  end
end
