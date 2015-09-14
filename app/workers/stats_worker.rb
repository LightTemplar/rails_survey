class StatsWorker
  include Sidekiq::Worker

  def perform(metric_id)
    metric = Metric.find(metric_id)
    metric.crunch_stats
  end

end