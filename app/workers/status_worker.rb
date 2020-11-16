class StatusWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'status'

  def perform(export_id)
    job = Sidekiq::ScheduledSet.new.find do |entry|
      entry.item['class'] == 'ResponseExportCompletionWorker' && entry.item['args'].first == export_id
    end
    ResponseExportCompletionWorker.perform_in(1.second, export_id) unless job

    export = ResponseExport.find(export_id)
    export.survey_exports.each do |survey_export|
      unless survey_export.last_response_at
        StatusWorker.perform_in(5.seconds, export_id)
        break
      end
    end
  end
end
