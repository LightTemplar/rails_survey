class StatusWorker
  include Sidekiq::Worker

  def perform(export_id)
    export = ResponseExport.find(export_id)
    sr = Sidekiq::RetrySet.new
    ss = Sidekiq::Stats.new
    if [sr.size, ss.enqueued].uniq.length == 1
      export.update(short_done: true, long_done: true, wide_done: true)
    else
      StatusWorker.perform_in(2.minute, export_id)
    end
  end

end