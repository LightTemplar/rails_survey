class StatsController < ApplicationController
  def index
    @metric = current_project.metrics.find(params[:metric_id])
    @stats = @metric.stats
  end

  def crunch
    metric = current_project.metrics.find(params[:metric_id])
    StatsWorker.perform_async(metric.id) if metric
    redirect_to project_metric_stats_path(current_project, metric)
  end
end
