class StatusWorker
  include Sidekiq::Worker

  def perform(export_id, filename)
    format = filename.split('_').last.split('.').first
    export = ResponseExport.find(export_id)
    if export.instrument.get_export_count("#{export_id}_#{format}") == '0'
      export.instrument.fetch_csv_data(filename, format, export_id)
      export.instrument.delete_export_count("#{export_id}_#{format}")
    else
      StatusWorker.perform_in(5.seconds, export_id, filename)
    end
  end
end
