Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_JOBS_URL'] }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_JOBS_URL'] }
end
