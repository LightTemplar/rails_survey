class ResponseExportsController < ApplicationController
  after_action :verify_authorized, :except => 
    [:index, :download_project_responses, :download_instrument_responses, :download_instrument_spss_csv,
      :download_project_response_images, :download_instrument_response_images, :download_spss_syntax_file,
      :download_project_spss_syntax_file, :download_project_spss_csv]
  
  def index
    @project_exports = current_project.response_exports.order('created_at DESC')
    @instrument_exports = current_project.instrument_response_exports
  end
  
  def new
    @project = current_project
    @export = current_project.response_exports.new
    authorize @export
  end
  
  def create
    @export = current_project.response_exports.new(params[:export])
    authorize @export
    if @export.save
      render text:"", notice: "Successfully created export."
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
    if @export.update_attributes(params[:export])
      render text:"", notice: "Successfully updated export."
    else
      render :edit
    end
  end
  
  def destroy
    @export = current_project.response_exports.find(params[:id])
    authorize @export
    @export.destroy
    render text:"", notice: "Successfully destroyed export."
  end
  
  def download_project_responses 
    export = ResponseExport.find params[:id]
    send_file export.download_url, :type => 'text/csv', :disposition => 'attachment', :filename => "#{ current_project.name.gsub(/\s+/,  '_') }" 
  end
  
  def download_instrument_responses
    export = ResponseExport.find params[:id]
    instrument = Instrument.find(export.instrument_id)
    send_file export.download_url, :type => 'text/csv', :disposition => 'attachment', :filename => "#{ instrument.title.gsub(/\s+/,  '_') }"
  end
  
  def download_project_response_images
    export = ResponseExport.find params[:id]
    send_file export.response_images_export.download_url, :type => 'application/zip', :disposition => 'attachment', :filename => "#{ current_project.name.gsub(/\s+/,  '_') }"
  end
  
  def download_instrument_response_images
    export = ResponseExport.find params[:id]
    instrument = Instrument.find(export.instrument_id)
    send_file export.response_images_export.download_url, :type => 'application/zip', :disposition => 'attachment', :filename => "#{ instrument.title.gsub(/\s+/,  '_') }"
  end
  
  def download_spss_syntax_file 
    export = ResponseExport.find params[:id]
    instrument = Instrument.find(export.instrument_id)
    send_file export.spss_syntax_file_url, :type => 'application/x-spss', :disposition => 'attachment', :filename => "#{ instrument.title.gsub!(/\s+/,  '_') }.sps"
  end
  
  def download_instrument_spss_csv
    export = ResponseExport.find params[:id]
    instrument = Instrument.find(export.instrument_id)
    send_file export.spss_friendly_csv_url, :type => 'text/csv', :disposition => 'attachment', :filename => "#{ instrument.title.gsub(/\s+/,  '_') }_spss"
  end
  
  def download_project_spss_syntax_file 
    export = ResponseExport.find params[:id]
    send_file export.spss_syntax_file_url, :type => 'application/x-spss', :disposition => 'attachment', :filename => "#{ current_project.name.gsub!(/\s+/,  '_') }.sps"
  end
  
  def download_project_spss_csv
    export = ResponseExport.find params[:id]
    send_file export.spss_friendly_csv_url, :type => 'text/csv', :disposition => 'attachment', :filename => "#{ current_project.name.gsub(/\s+/,  '_') }_spss"
  end
  
end
