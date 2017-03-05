# Use the 'whenever' gem to push jobs to Sidekiq on a regular interval
# Use the commmand line sidekiq client to run jobs on the same rails instance
# :path defaults to the directory in which whenever was executed
# :environment defaults to 'production'
job_type :sidekiq, 'cd :path && RAILS_ENV=:environment bundle exec sidekiq-client :task :output'

# Add the worker to the queue directly
every 1.day, at: '1:00 am' do
  sidekiq 'push CacheWarmerWorker'
end
