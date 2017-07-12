class CacheWarmerWorker
  include Sidekiq::Worker

  def perform
    Project.all.each do |project|
      CacheWorker.perform_async(project.id, 'device_users', 'api/v1/device_users/index')
      CacheWorker.perform_async(project.id, 'grid_labels', 'api/v1/grid_labels/index')
      CacheWorker.perform_async(project.id, 'grids', 'api/v1/grids/index')
      CacheWorker.perform_async(project.id, 'images', 'api/v1/images/index')
      CacheWorker.perform_async(project.id, 'instruments', 'api/v1/instruments/index')
      CacheWorker.perform_async(project.id, 'options', 'api/v1/options/index')
      CacheWorker.perform_async(project.id, 'questions', 'api/v1/questions/index')
      CacheWorker.perform_async(project.id, 'rules', 'api/v1/rules/index')
      CacheWorker.perform_async(project.id, 'skips', 'api/v1/skips/index')
      CacheWorker.perform_async(project.id, 'sections', 'api/v1/sections/index')
    end
  end
end
