class ResponseExportCompletionWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'percentage'

  def perform(id)
    export = ResponseExport.find id
    export.compute_completion if export
  end
end
