# == Schema Information
#
# Table name: stats
#
#  id         :integer          not null, primary key
#  metric_id  :integer
#  key_value  :string
#  count      :integer
#  percent    :string
#  created_at :datetime
#  updated_at :datetime
#

class Stat < ActiveRecord::Base
  belongs_to :metric

  def label
    metric.key_name == 'device_uuid' ? device_label : key_value
  end

  def device_label
    device = Device.find_by_identifier(key_value) if key_value
    if device && !device.label.blank?
      device.label
    else
      key_value
    end
  end

end
