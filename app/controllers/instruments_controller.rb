class InstrumentsController < ApplicationController
  after_action :verify_authorized
  
  def index
    @instruments = current_project.instruments
    authorize @instruments
  end

  def show
    @project = current_project
    @instrument = current_project.instruments.find(params[:id])
    authorize @instrument
  end

  def new
    @project = current_project
    @instrument = current_project.instruments.new
    authorize @instrument
  end

  def create
    @instrument = current_project.instruments.new(params[:instrument])
    authorize @instrument
    if @instrument.save
      redirect_to project_instrument_path(current_project, @instrument), notice: "Successfully created instrument."
    else
      render :new
    end
  end

  def edit
    @project = current_project
    @instrument = current_project.instruments.find(params[:id])
    authorize @instrument
  end

  def update
    @instrument = current_project.instruments.find(params[:id])
    authorize @instrument
    if @instrument.update_attributes(params[:instrument])
      redirect_to project_instrument_path(current_project, @instrument), notice: "Successfully updated instrument."
    else
      render :edit
    end
  end

  def destroy
    @instrument = current_project.instruments.find(params[:id])
    authorize @instrument
    @instrument.destroy
    redirect_to project_instruments_url, notice: "Successfully destroyed instrument."
  end

  def export
    @instrument = current_project.instruments.find(params[:id])
    authorize @instrument
    respond_to do |format|
      format.csv do 
        send_data @instrument.to_csv, 
          type: 'text/csv; charset=iso-8859-1; header=present',
          disposition: "attachment; filename=#{@instrument.title}_#{@instrument.current_version_number}.csv"
      end
    end
  end

  def export_responses
    @instrument = current_project.instruments.find(params[:id])
    authorize @instrument
    InstrumentExportsWorker.perform_async(@instrument.id)
    redirect_to project_exports_path(current_project)
  end
  
  def export_pictures
    @instrument = current_project.instruments.find(params[:id])
    authorize @instrument
    zipped_pictures = @instrument.response_images.to_zip(@instrument.title)
    send_file zipped_pictures.path, :type => 'application/zip', :disposition => 'attachment', :filename => "#{@instrument.title}" 
  end
  
end
