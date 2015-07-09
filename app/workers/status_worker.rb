class StatusWorker
  include Sidekiq::Worker
  
  def perform(export_id, job_id, job_type)
    if Sidekiq::Status::complete? job_id
      export = ResponseExport.find(export_id)
      if job_type == 'long_job'
        export.update_attributes(:long_done => true)
      elsif job_type == 'wide_job'
        export.update_attributes(:wide_done => true)
      else
        export.update_attributes(:short_done => true)
      end
    else
      StatusWorker.perform_in(1.minute, export_id, job_id, job_type)
    end
  end
   
end