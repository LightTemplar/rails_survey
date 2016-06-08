set :branch, 'master'
set :full_app_name, "#{fetch(:application)}_#{fetch(:stage)}"
set :deploy_to, '/var/www/rails_survey'
set :rails_env, :production
server 'wci-chpir.duke.edu:2222', user: 'dmtg', roles: %w{web app db}
#server 'adaptlab.vm.duke.edu:2222', user: 'dmtg', roles: %w{web app db}
#server 'pref-chpir.vm.duke.edu:2222', user: 'dmtg', roles: %w{web app db}
#server 'tz-chpir.vm.duke.edu:2222', user: 'dmtg', roles: %w{web app db}
# server '52.11.67.9:22', user: 'lkn8', roles: %w{web app db}