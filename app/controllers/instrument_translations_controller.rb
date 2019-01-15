class InstrumentTranslationsController < ApplicationController
  after_action :verify_authorized, except: [:import_translation]
  before_action :set_translation, only: [:show, :edit, :update, :destroy, :show_pdf]
  before_action :set_questions, only: [:new, :edit]
  before_action :set_randomized_options, only: [:new, :edit]

  def index
    @instrument = current_project.instruments.find(params[:instrument_id])
    @instrument_translations = @instrument.translations
    authorize @instrument_translations
  end

  def show
    authorize @instrument_translation
    respond_to do |format|
      format.html
      format.pdf do
        pdf = TranslationPdf.new(@instrument_translation)
        send_data pdf.render, filename: pdf.display_name, type: 'application/pdf'
      end
    end
  end

  def show_pdf
    authorize @instrument_translation
    respond_to do |format|
      format.pdf do
        render pdf: @instrument.title,
               template: 'instrument_translations/show',
               encoding: 'UTF-8'
      end
    end
  end

  def import_translation
    TranslationImportWorker.perform_async(params[:file].tempfile.path) if params[:file].content_type == 'text/csv'
    redirect_to project_instrument_instrument_translations_path(current_project, params[:instrument_id])
  end

  def new
    @project = current_project
    @instrument = current_project.instruments.find(params[:instrument_id])
    @instrument_translation = @instrument.translations.new
    authorize @instrument_translation
  end

  def new_gt
    @project = current_project
    @instrument = current_project.instruments.find(params[:instrument_id])
    @instrument_translation = @instrument.translations.new
    authorize @instrument_translation
  end

  def create
    @instrument = current_project.instruments.find(params[:instrument_id])
    @instrument_translation = @instrument.translations.new(instrument_translation_params)
    authorize @instrument_translation
    if @instrument_translation.save
      if request.referrer.split('/').last == 'new_gt'
        GoogleTranslateWorker.perform_async(@instrument_translation.id)
        redirect_to project_instrument_instrument_translations_path(current_project, @instrument), notice: 'Successfully created instrument translation.'
      else
        update_translations(params, @instrument, @instrument_translation)
        redirect_to project_instrument_instrument_translation_path(current_project, @instrument, @instrument_translation),
                    notice: 'Successfully created instrument translation.'
      end
    else
      render :new
    end
  end

  def edit
    @project = current_project
    authorize @instrument_translation
  end

  def update
    authorize @instrument_translation
    update_translations(params, @instrument, @instrument_translation)
    if @instrument_translation.update_attributes(instrument_translation_params)
      if params[:page].blank?
        redirect_to project_instrument_instrument_translation_path(current_project, @instrument, @instrument_translation),
                    notice: 'Successfully updated instrument translation.'
      else
        redirect_to action: :edit, page: params[:page]
      end
    else
      render :edit
    end
  end

  def destroy
    authorize @instrument_translation
    @instrument_translation.destroy
    redirect_to project_instrument_instrument_translations_url, notice: 'Successfully destroyed instrument translation.'
  end

  private

  def set_translation
    @instrument = current_project.instruments.find(params[:instrument_id])
    @instrument_translation = @instrument.translations.find(params[:id])
  end

  def set_questions
    instrument = current_project.instruments.find(params[:instrument_id])
    @questions = if params[:page].blank?
                   instrument.questions.page(1).per(5)
                 else
                   instrument.questions.page(params[:page]).per(5)
                 end
  end

  def set_randomized_options
    instrument = current_project.instruments.find(params[:instrument_id])
    @randomized_options = instrument.randomized_options
  end

  def update_translations(params, instrument, instrument_translation)
    if params.key? :question_translations
      params[:question_translations].each_pair do |id, translation|
        next if translation.blank?
        question = instrument.questions.find(id)
        q_translation = instrument_translation.translation_for(question)
        if q_translation && (q_translation.text != translation)
          q_translation.update_attribute(:question_changed, false)
        end
        question.add_or_update_translation_for(translation, :text, instrument_translation)
      end
    end

    if params.key? :validation_translations
      params[:validation_translations].each_pair do |id, translation|
        next if translation.blank?
        question = instrument.questions.find(id)
        question.add_or_update_translation_for(translation, :reg_ex_validation_message, instrument_translation)
      end
    end

    if params.key? :instructions_translations
      params[:instructions_translations].each_pair do |id, translation|
        next if translation.blank?
        question = instrument.questions.find(id)
        question.add_or_update_translation_for(translation, :instructions, instrument_translation)
      end
    end

    if params.key? :option_translations
      params[:option_translations].each_pair do |id, translation|
        next if translation.blank?
        option = Option.find(id)
        o_translation = instrument_translation.translation_for(option)
        if o_translation && (o_translation.text != translation)
          o_translation.update_attribute(:option_changed, false)
        end
        option.add_or_update_translation_for(translation, :text, instrument_translation)
      end
    end

    if params.key? :section_translations
      params[:section_translations].each_pair do |id, translation|
        next if translation.blank?
        section = instrument.sections.find(id)
        s_translation = instrument_translation.translation_for(section)
        if s_translation && (s_translation.text != translation)
          s_translation.update_attribute(:section_changed, false)
        end
        section.add_or_update_translation_for(translation, :text, instrument_translation)
      end
    end

    if params.key? :randomized_option_translations
      params[:randomized_option_translations].each_pair do |id, translation|
        next if translation.blank?
        randomized_option = instrument.randomized_options.find(id)
        randomized_option.add_or_update_translation_for(translation, :text, instrument_translation)
      end
    end

  end

  def instrument_translation_params
    params.require(:instrument_translation).permit(:title, :language, :alignment, :active)
  end
end
