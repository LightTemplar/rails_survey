module RedisJobTracker
  extend ActiveSupport::Concern

  def set_export_count(key, count)
    $redis.set(key, count)
  end

  def get_export_count(key)
    $redis.get(key)
  end

  def decrement_export_count(key)
    $redis.decr(key)
  end

  def delete_export_count(key)
    $redis.del(key)
  end
end
