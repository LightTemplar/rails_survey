# == Schema Information
#
# Table name: metrics
#
#  id            :integer          not null, primary key
#  instrument_id :integer
#  name          :string(255)
#  expected      :integer
#  key_name      :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

class Metric < ActiveRecord::Base
  belongs_to :instrument
  has_many :stats, dependent: :destroy
  validates_uniqueness_of :key_name, scope: :instrument_id

  def crunch_stats
    key_name == 'device_uuid' ? crunch_device_stats : crunch_metadata_stats
  end

  private
    def crunch_device_stats
      device_identifiers = instrument.surveys.select(:device_uuid).map(&:device_uuid).uniq
      device_identifiers.each do |uuid|
        count = instrument.surveys.where(device_uuid: uuid).count
        percentage = (count.to_f/expected.to_f).round(2).to_s if expected
        record_stat(uuid, count, percentage)
      end
    end

    def crunch_metadata_stats
      identifiers =  key_name == 'Center ID' ? instrument.surveys.collect{|survey| survey.center_id}.compact :
          instrument.surveys.collect{|survey| survey.participant_id}.compact
      identifiers.uniq.each do |id|
        count = identifiers.count { |s| s == id }
        percentage = (count.to_f/expected.to_f).round(2).to_s if expected
        record_stat(id, count, percentage)
      end
    end

    def record_stat(attr_name, count, percentage)
      stat = stats.where(key_value: attr_name).try(:first)
      if stat
        stat.update_attributes(count: count, percent: (percentage ? percentage : ''))
      else
        Stat.create(key_value: attr_name, metric_id: id, count: count, percent: (percentage ? percentage : ''))
      end
    end

end
