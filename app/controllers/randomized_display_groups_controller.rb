class RandomizedDisplayGroupsController < ApplicationController
  before_action :set_randomized_display_group, only: [:show, :edit, :update, :destroy]

  def index
    @instrument = current_project.instruments.find(params[:instrument_id])
    @randomized_display_groups = @instrument.randomized_display_groups
  end

  def new
    @instrument = current_project.instruments.find(params[:instrument_id])
    @randomized_display_group = @instrument.randomized_display_groups.new
    @display_groups = @randomized_display_group.display_groups
  end

  def show
  end

  def edit
    @display_groups = @randomized_display_group.display_groups
  end

  def create
    @instrument = current_project.instruments.find(params[:instrument_id])
    @randomized_display_group = @instrument.randomized_display_groups.new(randomized_display_group_params)
    respond_to do |format|
      if @randomized_display_group.save
        # update_question_association
        format.html { redirect_to project_instrument_randomized_display_groups_path(current_project, @instrument),
          notice: 'Randomized Display Group was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end



  def update
    @instrument = current_project.instruments.find(params[:instrument_id])
    @randomized_display_group = @instrument.randomized_display_groups.find(params[:id])
    respond_to do |format|
      if @randomized_display_group.update(randomized_display_group_params)
        # update_question_association
        format.html { redirect_to project_instrument_randomized_display_groups_path(current_project,
          @instrument), notice: 'Randomized Display Group was successfully updated.' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  def destroy
    @instrument = current_project.instruments.find(params[:instrument_id])
    @randomized_display_group = @instrument.randomized_display_groups.find(params[:id])
    @randomized_display_group.destroy
    respond_to do |format|
      format.html { redirect_to project_instrument_randomized_display_groups_path(current_project, @instrument) }
    end
  end

  private
    def set_randomized_display_group
      @instrument = current_project.instruments.find(params[:instrument_id])
      @randomized_display_group = @instrument.randomized_display_groups.find(params[:id])
    end

    def randomized_display_group_params
      params.require(:randomized_display_group).permit(:title, :instrument_id, display_group_ids: [])
    end

    # def update_question_association
    #   @section.questions.clear
    #   questions = @instrument.questions.where(id: params[:section][:question_ids])
    #   questions.update_all(section_id: @section.id) unless questions.blank?
    # end
end
