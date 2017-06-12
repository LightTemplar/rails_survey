require 'capistrano/setup'
require 'capistrano/deploy'
require 'capistrano/scm/git'
install_plugin Capistrano::SCM::Git
require 'sshkit/dsl'
require 'capistrano/rvm'
require 'capistrano/bundler'
require 'capistrano/rails/assets'
require 'capistrano/sidekiq'
require 'capistrano/sidekiq/monit'
require 'capistrano/rails/migrations'
require 'whenever/capistrano'

Dir.glob('lib/capistrano/tasks/*.cap').each { |r| import r }
