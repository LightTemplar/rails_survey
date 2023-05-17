# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
RailsSurvey::Application.initialize!

# Using SendGrid
ActionMailer::Base.smtp_settings = {
  user_name: ENV['SMTP_USERNAME'],
  password: ENV['SMTP_PASSWORD'],
  domain: ENV['SMTP_DOMAIN'],
  address: ENV['SMTP_ADDRESS'],
  port: ENV['SMTP_PORT'],
  authentication: :plain,
  enable_starttls_auto: true
}
