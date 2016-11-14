workers 4
threads 0,32
preload_app!

before_fork do
  ActiveRecord::Base.connection.disconnect!
end

on_worker_boot do
  ActiveRecord::Base.establish_connection
end