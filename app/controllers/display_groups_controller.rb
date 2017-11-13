class DisplayGroupsController < ApplicationController
  before_action :set_route_params

  def show
    @display_group = @randomized_display_group.display_groups.find(params[:id])
  end

  def new
    @display_group = @randomized_display_group.display_groups.new
    @questions = @instrument.questions
  end

  def edit
    @display_group = @randomized_display_group.display_groups.find(params[:id])
    @questions = @instrument.questions
  end

  def create
    @display_group = @randomized_display_group.display_groups.new(display_group_params)
    respond_to do |format|
      if @display_group.save
        update_question_association
        format.html { redirect_to project_instrument_randomized_display_group_path(
          current_project, @instrument, @randomized_display_group),
          notice: 'Display Group was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  def update
    @display_group = @randomized_display_group.display_groups.find(params[:id])
    respond_to do |format|
      if @display_group.update(display_group_params)
        update_question_association
        format.html { redirect_to project_instrument_randomized_display_group_display_group_path(
          current_project, @instrument, @randomized_display_group, @display_group),
          notice: 'Display Group was successfully updated.' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  def destroy
    @display_group = @randomized_display_group.display_groups.find(params[:id])
    @display_group.destroy
    respond_to do |format|
      format.html { redirect_to project_instrument_randomized_display_group_path(
        current_project, @instrument, @randomized_display_group) }
    end
  end

  private

  def update_question_association
    @display_group.questions.clear
    questions = @instrument.questions.where(id: params[:display_group][:question_ids])
    questions.update_all(display_group_id: @display_group.id) unless questions.blank?
  end

  def set_route_params
    @instrument = current_project.instruments.find(params[:instrument_id])
    @randomized_display_group = @instrument.randomized_display_groups.find(params[:randomized_display_group_id])
  end

  def display_group_params
    params.require(:display_group).permit(:title, :instrument_id, :position, question_ids: [])
  end
end
