class StatusWorker
  include Sidekiq::Worker

  def perform(export_id)
    export = ResponseExport.find(export_id)
    if Survey.get_export_count(export_id.to_s) == '0'
      export.update(short_done: true, long_done: true, wide_done: true)
      Survey.delete_export_count(export_id.to_s)
    else
      StatusWorker.perform_in(5.seconds, export_id)
    end
  end

end