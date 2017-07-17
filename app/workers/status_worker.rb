class StatusWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'status'

  def perform(export_id, format)
    export = ResponseExport.find(export_id)
    if export.instrument.get_export_count("#{export_id}_#{format}") == '0'
      export.instrument.stringify_arrays(format)
      export.instrument.delete_export_count("#{export_id}_#{format}")
    else
      StatusWorker.perform_in(5.seconds, export_id, format)
    end
  end
end
