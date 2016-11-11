module AsJsonAble
  extend ActiveSupport::Concern

  def as_json(options={})
    Rails.cache.fetch("#{cache_key}/as_json") do
      super(options)
    end
  end

end