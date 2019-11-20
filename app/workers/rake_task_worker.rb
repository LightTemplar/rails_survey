# frozen_string_literal: true

require 'rake'
Rake::Task.clear
Rails.application.load_tasks
class RakeTaskWorker
  include Sidekiq::Worker

  def perform(task_name, args = '')
    Rake::Task[task_name].reenable
    Rake::Task[task_name].invoke(args)
  end
end
