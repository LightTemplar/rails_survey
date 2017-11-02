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
    @instrument = current_project.instruments.find params[:id]
    authorize @instrument
    @instrument.export_surveys(true)
    redirect_to project_response_exports_path(current_project)
  end

  def translation_template_export
    @instrument = current_project.instruments.find(params[:id])
    authorize @instrument
    respond_to do |format|
      format.csv do
        send_data @instrument.translation_csv_template,
                  type: 'text/csv; charset=iso-8859-1; header=present',
                  disposition: "attachment; filename=#{@instrument.title}_translation_template.csv"
      end
    end
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
    if @instrument.update_attributes(project_id: params[:end_project])
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
    system "bundle exec rake instrument:copy[#{@instrument.id},#{params[:end_project]}] --trace 2>&1 >> #{Rails.root}/log/rake.log &"
    redirect_to project_path current_project
  end

  def copy_questions
    @project = current_project
    @instrument = @project.instruments.find(params[:id])
    authorize @instrument
  end

  def questions
    @project = current_project
    @instrument = current_project.instruments.find(params[:id])
    authorize @instrument
  end

  private

  def instrument_params
    params.require(:instrument).permit(:title, :language, :alignment, :previous_question_count, :child_update_count, :published, :project_id, :show_instructions, :show_sections_page, :roster, :roster_type, :navigate_to_review_page, :critical_message, :scorable, :auto_export_responses, special_options: [])
  end
end
