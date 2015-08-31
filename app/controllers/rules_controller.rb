class RulesController < ApplicationController
  def index
    @rules = current_project.rules
    authorize @rules
  end

  def show
  end

  def edit
    @rule = current_project.rules.find(params[:id])
    authorize @rule
  end

  def update
    @rule = current_project.rules.find(params[:id])
    authorize @rule
    if @rule.update(rule_params)
      redirect_to project_rules_path(current_project), notice: 'Rule was successfully updated.'
    else
      render :edit
    end
  end

  def new
    @rule = current_project.rules.new
    authorize @rule
  end

  def create
    @rule = current_project.rules.new(rule_params)
    authorize @rule
    if @rule.save
      redirect_to project_rules_path(current_project), notice: 'Rule was successfully created.'
    else
      render :new
    end
  end
  
  def destroy
    @rule = current_project.rules.find(params[:id])
    authorize @rule
    @rule.destroy
    redirect_to project_rules_url(current_project)
  end

  private
  def rule_params
    params.require(:rule).permit(:instrument_id, :rule_type, :rule_params)
  end
end
