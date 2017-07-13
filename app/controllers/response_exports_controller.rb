class ResponseExportsController < ApplicationController
  after_action :verify_authorized, except: [:index, :show, :instrument_responses_long, :instrument_responses_wide, :instrument_responses_short, :project_response_images, :instrument_response_images]

  def index
    @project_exports = current_project.response_exports.order('created_at DESC').limit(10)
    @instrument_exports = current_project.instrument_response_exports.take(30)
  end

  def new
    @project = current_project
    @export = current_project.response_exports.new
    authorize @export
  end

  def show
    @export = current_project.instrument_response_exports.find(params[:id])
  end

  def create
    @export = current_project.response_exports.new(response_export_params)
    authorize @export
    if @export.save
      render text: '', notice: 'Successfully created export.'
    else
      render :new
    end
  end

  def edit
    @project = current_project
    @export = current_project.response_exports.find(params[:id])
    authorize @export
  end

  def update
    @export = current_project.response_exports.find(params[:id])
    authorize @export
    if @export.update_attributes(response_export_params)
      render text: '', notice: 'Successfully updated export.'
    else
      render :edit
    end
  end

  def destroy
    @export = current_project.response_exports.find(params[:id])
    authorize @export
    @export.destroy
    render text: '', notice: 'Successfully destroyed export.'
  end

  # def project_responses_long
  #   export = current_project.response_exports.find params[:id]
  #   download_file(export.long_format_url, 'text/csv', export_name(current_project.name, 'long', '.csv'))
  # end

  # def project_responses_wide
  #   export = current_project.response_exports.find params[:id]
  #   download_file(export.wide_format_url, 'text/csv', export_name(current_project.name, 'wide', '.csv'))
  # end

  # def project_responses_short
  #   export = current_project.response_exports.find params[:id]
  #   download_file(export.short_format_url, 'text/csv', export_name(current_project.name, 'short', '.csv'))
  # end

  # TODO: Ensure Tempfile is deleted
  def instrument_responses_long
    export = ResponseExport.find(params[:id])
    download_file(export.export_file('long').path, 'text/csv', export_name(export.instrument.title, 'long', '.csv')) if export.instrument
  end

  def instrument_responses_wide
    export = ResponseExport.find(params[:id])
    download_file(export.export_file('wide').path, 'text/csv', export_name(export.instrument.title, 'wide', '.csv')) if export.instrument
  end

  def instrument_responses_short
    export = ResponseExport.find(params[:id])
    download_file(export.export_file('short').path, 'text/csv', export_name(export.instrument.title, 'short', '.csv')) if export.instrument
  end

  def project_response_images
    export = current_project.response_exports.find(params[:id])
    download_file(export.response_images_export.download_url, 'application/zip',
                  export_name(current_project.name, '', '.zip'))
  end

  def instrument_response_images
    export = ResponseExport.find(params[:id])
    instrument = current_project.instruments.find(export.instrument_id)
    download_file(export.response_images_export.download_url, 'application/zip',
                  export_name(instrument.title, '', '.zip'))
  end

  private

  def download_file(url, type, filename)
    send_file url, type: type, disposition: 'attachment', filename: filename
  end

  def response_export_params
    params.require(:response_export).permit(:project_id, :instrument_id, :instrument_versions, :long_done, :wide_done, :short_done)
  end

  def export_name(str, format, extension)
    str.gsub(/\s+/, '_').to_s + '_' + format + '_' + Time.now.strftime('%Y_%m_%d_%H_%M_%S') + extension
  end
end
