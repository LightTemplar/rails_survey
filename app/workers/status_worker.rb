class StatusWorker
  include Sidekiq::Worker
  
  def perform(export_id, job_type, total)
      export = ResponseExport.find(export_id)
      if job_type == 'long_job' && total == $redis.get("#{export_id}_long_job_count")
        export.update_attributes(:long_done => true)
      elsif job_type == 'wide_job' && total == $redis.get("#{export_id}_wide_job_count")
        export.update_attributes(:wide_done => true)
      elsif job_type == 'short_job' && total == $redis.get("#{export_id}_short_job_count")
        export.update_attributes(:short_done => true)
      else
        rs = Sidekiq::RetrySet.new
        ss = Sidekiq::ScheduledSet.new
        ww = Sidekiq::Workers.new
        if [rs.size, ss.size, ww.size].uniq.length == 1
          export.update(short_done: true, long_done: true, wide_done: true)
        else
          StatusWorker.perform_in(2.minute, export_id, job_type, total)
        end
      end
  end
   
end