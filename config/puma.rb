workers 4
threads 1,1 #having more than one thread causes circular dependency errors when auto-loading controllers
preload_app!

before_fork do
  ActiveRecord::Base.connection.disconnect!
end

on_worker_boot do
  ActiveRecord::Base.establish_connection
end