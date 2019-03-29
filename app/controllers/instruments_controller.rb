# frozen_string_literal: true

class InstrumentsController < ApplicationController
  after_action :verify_authorized

  def index
    @instruments = current_project.instruments
    authorize @instruments
  end

  def show
    project = current_user.projects.find(params[:project_id])
    @language = params[:language]
    @instrument = project.instruments.includes(displays: [:instrument, instrument_questions:
      [:instrument, :next_questions, :multiple_skips, :loop_questions, :critical_responses,
       :taggings, display_instructions: %i[display instruction taggings],
                  question: [:instruction, :special_option_set, option_set: %i[instruction]]]]).find(params[:id])
    authorize @instrument
    respond_to do |format|
      format.html { render layout: 'pdf.html' }
      format.pdf do
        render pdf: @instrument.title,
               template: 'instruments/show',
               layout: 'pdf.html',
               encoding: 'UTF-8',
               margin: { top: 10, bottom: 15, left: 10, right: 10 },
               header: { right: '[page] of [topage]' }
      end
    end
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
    @instrument.export_surveys
    unless @instrument.response_images.empty?
      zipped_file = File.new(File.join('files', 'exports').to_s + "/#{Time.now.to_i}.zip", 'a+')
      zipped_file.close
      pictures_export = ResponseImagesExport.create(response_export_id: @instrument.response_export.id, download_url: zipped_file.path)
      InstrumentImagesExportWorker.perform_async(@instrument.id, zipped_file.path, pictures_export.id)
    end
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
    redirect_to project_path(@project) if @instrument.update_attributes(project_id: params[:end_project])
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
    params.require(:instrument).permit(:title, :language, :alignment, :previous_question_count, :child_update_count, :published, :project_id, :show_instructions, :show_sections_page, :roster, :roster_type, :navigate_to_review_page, :scorable, :auto_export_responses, special_options: [])
  end
end
