module Syncable
  extend ActiveSupport::Concern

  def to_sync(association, table_name, last_sync_time)
    return association.with_deleted if last_sync_time.blank?
    previous_sync_time = Time.at(last_sync_time.to_i/1000).to_datetime
    association.with_deleted.where("#{table_name}.updated_at >= ?", previous_sync_time)
  end

end