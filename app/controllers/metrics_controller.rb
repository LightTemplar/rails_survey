class MetricsController < ApplicationController

  def index
    @metrics = current_project.metrics
  end

  def new
    @project = current_project
    @metric = current_project.metrics.new
  end

  def edit
    @project = current_project
    @metric = @project.metrics.find(params[:id])
  end

  def create
    @project = current_project
    @metric = @project.metrics.new(metric_params)
    if @metric.save
      redirect_to project_metrics_path(current_project), notice: 'Successfully created metric.'
    else
      render :new
    end
  end

  def update
    @project = current_project
    @metric = @project.metrics.find(params[:id])
    if @metric.update_attributes(metric_params)
      redirect_to project_metrics_path(current_project), notice: 'Successfully updated metric.'
    else
      render :edit
    end
  end

  def destroy
    @metric = current_project.metrics.find(params[:id])
    @metric.destroy
    redirect_to project_metrics_path(current_project), notice: 'Successfully destroyed metric.'
  end

  private

    def metric_params
      params.require(:metric).permit(:instrument_id, :name, :expected, :key_name)
    end
end
