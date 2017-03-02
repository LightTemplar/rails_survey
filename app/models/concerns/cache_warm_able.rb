module CacheWarmAble
  extend ActiveSupport::Concern

  included do
    after_save :warm_cache
    class CacheWarmerWorker
      include Sidekiq::Worker

      def perform(model, id)
        obj = model.constantize.find(id)
        obj.to_json if obj
      end
    end
  end

  def warm_cache
    CacheWarmerWorker.perform_async(self.class.name, id)
  end
end
