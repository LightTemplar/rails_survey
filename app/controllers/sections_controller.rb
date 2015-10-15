class SectionsController < ApplicationController
  before_action :set_section, only: [:show, :edit, :update, :destroy]

  def index
    @instrument = current_project.instruments.find(params[:instrument_id])
    @sections = @instrument.sections 
  end

  def new
    @instrument = current_project.instruments.find(params[:instrument_id])
    @section = @instrument.sections.new
    @questions = @instrument.questions.where(section_id: nil)
  end

  def show
  end

  def edit
    @questions = @section.questions + @instrument.questions.where(section_id: nil)
  end

  def create
    @instrument = current_project.instruments.find(params[:instrument_id])
    @section = @instrument.sections.new(section_params)
    respond_to do |format|
      if @section.save
        update_question_association
        format.html { redirect_to project_instrument_sections_path(current_project, @instrument), notice: 'Section was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end



  def update
    @instrument = current_project.instruments.find(params[:instrument_id])
    @section = @instrument.sections.find(params[:id])
    respond_to do |format|
      if @section.update(section_params)
        update_question_association
        format.html { redirect_to project_instrument_sections_path(current_project, @instrument), notice: 'Section was successfully updated.' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  def destroy
     @instrument = current_project.instruments.find(params[:instrument_id])
    @section = @instrument.sections.find(params[:id])
    @section.destroy
    respond_to do |format|
      format.html { redirect_to project_instrument_sections_path(current_project, @instrument) }
    end
  end

  private
    def set_section
      @instrument = current_project.instruments.find(params[:instrument_id])
      @section = @instrument.sections.find(params[:id])
    end

    def section_params
      params.require(:section).permit(:title, :instrument_id, question_ids: [])
    end

    def update_question_association
      @section.questions.clear
      questions = @instrument.questions.where(id: params[:section][:question_ids])
      questions.update_all(section_id: @section.id) unless questions.blank?
    end
end
