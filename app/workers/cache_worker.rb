class CacheWorker
  include Sidekiq::Worker

  def perform(project_id, association_name, template_path)
    project = Project.find project_id
    return unless project
    Rabl::Renderer.json(project.send(association_name), template_path)
  end
end
