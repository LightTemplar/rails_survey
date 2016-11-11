module SynchAble
  extend ActiveSupport::Concern

  def paranoid_synch_models(table_name, last_synch_time)
    cache_key_1 = "#{self.id}#{self.send(table_name).maximum(:updated_at).try(:to_i)}-#{table_name}"
    association = Rails.cache.fetch(cache_key_1) do
      if table_name == 'questions'
        self.send(table_name).includes(:instrument)
      elsif table_name == 'options'
        self.send(table_name).includes(:grid_label, question: [:instrument])
      else
        self.send(table_name)
      end
    end
    if association.respond_to? :translations
      fetch_associations(association, last_synch_time, cache_key_1 + '-2', table_name).includes(:translations)
    else
      fetch_associations(association, last_synch_time, cache_key_1 + '-2', table_name)
    end
  end

  def synch_models(table_name, last_synch_time)
    cache_key_1 = "#{self.id}#{self.send(table_name).maximum(:updated_at).try(:to_i)}-#{table_name}"
    association = Rails.cache.fetch(cache_key_1) do
      self.send(table_name)
    end
    if last_synch_time.blank?
      Rails.cache.fetch(cache_key_1 + '-2') do
        association
      end
    else
      previous_synch_time = Time.at(last_synch_time.to_i/1000).to_datetime
      association.where("#{table_name}.updated_at >= ?", previous_synch_time)
    end
  end

  private
  def fetch_associations(association, last_synch_time, key, name)
    if last_synch_time.blank?
      Rails.cache.fetch(key + '-2') do
        association.with_deleted
      end
    else
      previous_synch_time = Time.at(last_synch_time.to_i/1000).to_datetime
      association.with_deleted.where("#{name}.updated_at >= ?", previous_synch_time)
    end
  end

end