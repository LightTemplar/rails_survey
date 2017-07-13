# == Schema Information
#
# Table name: response_exports
#
#  id                  :integer          not null, primary key
#  long_done           :boolean          default(FALSE)
#  created_at          :datetime
#  updated_at          :datetime
#  project_id          :integer
#  instrument_id       :integer
#  instrument_versions :text
#  wide_done           :boolean          default(FALSE)
#  short_done          :boolean          default(FALSE)
#

class ResponseExport < ActiveRecord::Base
  serialize :instrument_versions
  belongs_to :project
  belongs_to :instrument
  has_one :response_images_export, dependent: :destroy

  def percent_complete
    total = instrument.surveys.count * 3.0
    long = instrument.get_export_count("#{id}_long")
    short = instrument.get_export_count("#{id}_short")
    wide = instrument.get_export_count("#{id}_wide")
    remainder = long.to_i + short.to_i + wide.to_i
    if remainder > 0
      percent = ((total - remainder.to_f) / total) * 100
      percent = percent.round
    else
      percent = 100
    end
    if percent >= 100 && !wide_done && !short_done && !long_done
      update_columns(short_done: true, long_done: true, wide_done: true)
    end
    percent
  end

  def export_file(format)
    csv_data = $redis.get "#{instrument_id}-#{id}-#{format}"
    data = JSON.parse(csv_data)
    file = Tempfile.new("#{instrument_id}-#{id}-#{format}")
    CSV.open(file, 'a+') do |csv|
      csv << csv_headers(format)
      data.each do |row|
        csv << row
      end
    end
    file
  end

  private

  def csv_data(format)
    data = $redis.get "#{instrument_id}-#{id}-#{format}"
    JSON.parse(data)
  end

  def csv_headers(format)
    if format == 'short'
      instrument.short_headers
    elsif format == 'long'
      instrument.long_headers
    elsif format == 'wide'
      instrument.wide_headers
    end
  end
end
