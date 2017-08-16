class BoxUploadWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'upload'

  def perform(response_export_id, format, name, filename)
    response_export = ResponseExport.find(response_export_id)
    filepath = response_export.export_file(format).path
    client = BoxClientUploader.new
    folder = client.folder_with_name(name)
    client.upload_file(filepath, folder, filename)
  end
end
