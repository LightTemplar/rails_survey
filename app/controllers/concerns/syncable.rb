module Syncable
  extend ActiveSupport::Concern

  def to_sync(association, table_name, last_sync_time)
    return association.with_deleted if last_sync_time.blank?
    previous_sync_time = DateTime.iso8601(last_sync_time)
    association.with_deleted.where("#{table_name}.updated_at >= ?", previous_sync_time)
  end

end