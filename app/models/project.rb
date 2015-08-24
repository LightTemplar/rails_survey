# == Schema Information
#
# Table name: projects
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

class Project < ActiveRecord::Base
  attr_accessible :name, :description
  has_many :instruments, dependent: :destroy
  has_many :surveys, through: :instruments
  has_many :project_devices, dependent: :destroy
  has_many :devices, through: :project_devices
  has_many :responses, through: :surveys
  has_many :response_images, through: :responses
  has_many :user_projects
  has_many :users, through: :user_projects
  has_many :response_exports 
  has_many :response_images_exports, through: :response_exports
  has_many :questions, through: :instruments
  has_many :images, through: :questions
  has_many :options, through: :questions
  has_many :sections, through: :instruments
  has_many :project_device_users
  has_many :device_users, through: :project_device_users
  has_many :skips, through: :options 
  has_many :rules, through: :instruments
  has_many :grids, through: :instruments
  has_many :grid_labels, through: :grids
  
  validates :name, presence: true, allow_blank: false
  validates :description, presence: true, allow_blank: true

  def non_responsive_devices
    devices.includes(:surveys).where('surveys.updated_at < ?', Settings.danger_zone_days.days.ago).order('surveys.updated_at ASC')
  end

  def instrument_response_exports
    ResponseExport.where(instrument_id: instrument_ids).order('created_at desc')
  end

  def daily_response_count 
    count_per_day = {}
    array = []
    response_count_per_period(:group_responses_by_day).each do |day, count|
      count_per_day[day.to_s[5..9]] = count.inject{|sum,x| sum + x}
    end
    array << count_per_day
  end
  
  def hourly_response_count
    count_per_hour = {}
    array = []
    response_count_per_period(:group_responses_by_hour).each do |hour, count|
      count_per_hour[hour.to_s] = count.inject{|sum,x| sum + x}
    end
    puts sanitize(count_per_hour)
    array << sanitize(count_per_hour)
  end

  def export_responses
    root = File.join('files', 'exports').to_s
    short_csv = File.new(root + "/#{Time.now.to_i}_#{name}_short.csv", 'a+')
    wide_csv = File.new(root + "/#{Time.now.to_i}_#{name}_wide.csv", 'a+')
    long_csv = File.new(root + "/#{Time.now.to_i}_#{name}_long.csv", 'a+')
    long_csv.close
    wide_csv.close
    short_csv.close
    export = ResponseExport.create(:project_id => id, :short_format_url => short_csv.path, :wide_format_url => wide_csv.path, :long_format_url => long_csv.path)
    Survey.write_short_header(short_csv)
    Survey.write_long_header(long_csv, self)
    Survey.write_wide_header(wide_csv, self)
    instruments(include: :surveys).each do |instrument|
      Survey.export_wide_csv(wide_csv, instrument, export.id)
      Survey.export_short_csv(short_csv, instrument, export.id)
      Survey.export_long_csv(long_csv, instrument, export.id)
    end
    Survey.set_export_count(export.id.to_s, surveys.count * 3)
    StatusWorker.perform_in(5.minutes, export.id)
  end

  def device_surveys(device)
    surveys.where(device_uuid: device.identifier)
  end

  private
  def sanitize(hash)
    (0..23).each do |h|
      hour = sprintf '%02d', h
      hash[hour] = 0 unless hash.has_key?(hour)
    end
    hash
  end
  
  def response_count_per_period(method)
    grouped_responses = []
    self.instruments.each do |instrument|
      instrument.surveys.each do |survey|
        grouped_responses << survey.send(method)
      end
    end
    merge_period_counts(grouped_responses)
  end
  
  def merge_period_counts(grouped_responses)
    grouped_responses.map(&:to_a).flatten(1).reduce({}) {|h,(k,v)| (h[k] ||= []) << v; h}
  end
  
end
