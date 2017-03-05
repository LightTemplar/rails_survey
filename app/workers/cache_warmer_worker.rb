class CacheWarmerWorker
  include Sidekiq::Worker

  def perform
    Project.all.each do |project|
      Rabl::Renderer.json(project.device_users, 'api/v1/device_users/index')
      Rabl::Renderer.json(project.grid_labels, 'api/v1/grid_labels/index')
      Rabl::Renderer.json(project.grids, 'api/v1/grids/index')
      Rabl::Renderer.json(project.images, 'api/v1/images/index')
      Rabl::Renderer.json(project.instruments, 'api/v1/instruments/index')
      Rabl::Renderer.json(project.options, 'api/v1/options/index')
      Rabl::Renderer.json(project.questions, 'api/v1/questions/index')
      Rabl::Renderer.json(project.rules, 'api/v1/rules/index')
      Rabl::Renderer.json(project.skips, 'api/v1/skips/index')
      Rabl::Renderer.json(project.sections, 'api/v1/sections/index')
    end
  end
end
