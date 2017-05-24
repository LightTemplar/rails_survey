# Be sure to restart your server when you modify this file.

RailsSurvey::Application.config.session_store :cookie_store, key: "_#{ENV['INSTANCE_NAME']}_session"
