# frozen_string_literal: true

class ResponseExportCompletionWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'percentage'

  def perform(id)
    export = ResponseExport.find id
    export&.compute_completion
  end
end
