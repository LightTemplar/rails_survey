# frozen_string_literal: true

class Api::V4::InstrumentsController < Api::V4::ApiController
  include ActionController::MimeResponds
  respond_to :json, :pdf
  before_action :set_project, only: %i[index show create update destroy pdf_export]
  before_action :set_instrument, only: %i[update destroy pdf_export]

  def index
    @instruments = @project.instruments.order('title')
  end

  def show
    @instrument = @project.instruments.find(params[:id])
  end

  def create
    instrument = @project.instruments.new(instrument_params)
    if instrument.save
      redirect_to action: 'show', id: instrument.id
    else
      render json: { errors: instrument.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @instrument.update_attributes(instrument_params)
      @instrument
    else
      render json: { errors: @instrument.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    respond_with @instrument.destroy
  end

  def pdf_export
    respond_to do |format|
      format.pdf do
        pdf = if params[:language] == 'en'
                InstrumentPdf.new(@instrument, params[:column_count])
              else
                TranslationPdf.new(@instrument, params[:language], params[:column_count])
              end
        send_data pdf.render, filename: pdf.display_name, type: 'application/pdf'
      end
    end
  end

  private

  def instrument_params
    params.require(:instrument).permit(:title, :language, :published, :project_id)
  end

  def set_project
    @project = current_user.projects.find(params[:project_id])
  end

  def set_instrument
    @instrument = @project.instruments.find(params[:id])
  end
end
