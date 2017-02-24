require File.expand_path('../boot', __FILE__)

require 'csv'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module RailsSurvey
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.assets.paths << Rails.root.join('vendor', 'assets', 'images')
    config.assets.paths << Rails.root.join('vendor', 'assets', 'lib')
    config.assets.paths << Rails.root.join('vendor', 'assets', 'fonts')
    I18n.enforce_available_locales = false
    config.assets.initialize_on_precompile = false
    config.assets.precompile += %w(active_admin.js active_admin.css.scss)
    config.wiki_path = 'wiki.git'
    config.cache_store = :redis_store, 'redis://localhost:6379/0/cache'
    config.autoload_paths += Dir[Rails.root.join('app', 'scorers', '{*/}')]
  end
end
