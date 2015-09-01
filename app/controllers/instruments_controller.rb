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
    @instrument = current_project.instruments.new(instrument_params)
    authorize @instrument
    if @instrument.save
      redirect_to project_instrument_path(current_project, @instrument), notice: 'Successfully created instrument.'
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
    if @instrument.update_attributes(instrument_params)
      redirect_to project_instrument_path(current_project, @instrument), notice: 'Successfully updated instrument.'
    else
      render :edit
    end
  end

  def destroy
    @instrument = current_project.instruments.find(params[:id])
    authorize @instrument
    @instrument.destroy
    redirect_to project_instruments_url, notice: 'Successfully destroyed instrument.'
  end

  def csv_export
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

  def pdf_export
    @instrument = current_project.instruments.find(params[:id])
    authorize @instrument
    respond_to do |format|
      format.pdf do
        pdf = InstrumentPdf.new(@instrument)
        send_data pdf.render, filename: pdf.display_name, type: 'application/pdf'
      end
    end
  end

  def export_responses
    @instrument = current_project.instruments.includes(:surveys).where(id: params[:id]).try(:first)
    authorize @instrument
    export_id = Survey.instrument_export(@instrument)
    unless @instrument.response_images.empty?
      zipped_file = File.new(File.join('files', 'exports').to_s + "/#{Time.now.to_i}.zip", 'a+')
      zipped_file.close
      pictures_export = ResponseImagesExport.create(:response_export_id => export_id, :download_url => zipped_file.path)
      InstrumentImagesExportWorker.perform_async(@instrument.id, zipped_file.path, pictures_export.id)
    end
    redirect_to project_response_exports_path(current_project)
  end

  def move
    @projects = current_user.projects
    @instrument = current_project.instruments.find(params[:id])
    authorize @instrument
  end

  def update_move
    @instrument = current_project.instruments.find(params[:id])
    authorize @instrument
    @project = current_user.projects.find(params[:project_id])
    if @instrument.update_attributes(:project_id => params[:end_project])
      redirect_to project_path(@project)
    end
  end

  def copy
    @projects = current_user.projects
    @instrument = current_project.instruments.find(params[:id])
    authorize @instrument
  end

  def update_copy
    @instrument = current_project.instruments.find(params[:id])
    authorize @instrument
    InstrumentCopyWorker.perform_async(@instrument.id, params[:end_project].to_i)
    redirect_to project_path current_project
  end

  private
  def instrument_params
    params.require(:instrument).permit(:title, :language, :alignment, :previous_question_count, :child_update_count,
                                       :published, :show_instructions, :project_id)
  end

end