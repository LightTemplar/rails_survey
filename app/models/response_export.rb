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
#  completion          :decimal(5, 2)    default(0.0)
#

class ResponseExport < ActiveRecord::Base
  serialize :instrument_versions
  # belongs_to :project
  belongs_to :instrument
  has_one :response_images_export, dependent: :destroy

  def completion
    read_attribute(:completion)
  end

  def compute_completion
    total = instrument.surveys.count * 3.0
    return if total == 0.0
    remainder = %w(long short wide).inject(0){|sum,e| sum += instrument.get_export_count("#{id}_#{e}").to_i}
    percent = 100
    percent = (((total - remainder.to_f) / total) * 100).round if remainder > 0
    if percent >= 100 && (!wide_done || !short_done || !long_done)
      update_columns(short_done: true, long_done: true, wide_done: true)
    end
    update_column(:completion, percent)
  end

  def export_file(format)
    csv_data = $redis.get "#{instrument_id}-#{id}-#{format}"
    data = csv_data.nil? ? nil : JSON.parse(csv_data)
    unless data.nil?
      data = data.reject{|arr| arr.all?(&:blank?)}
      data = data.sort {|ar1,ar2| ar1[0].to_i <=> ar2[0].to_i}
    end
    file = Tempfile.new("#{instrument_id}-#{id}-#{format}")
    CSV.open(file, 'w') do |csv|
      csv << csv_headers(format)
      if data
        data.each do |row|
          csv << row
        end
      else
        instrument.export_surveys if instrument.surveys.count > 0
      end
    end
    file
  end

  # Re-export under the following circumstances:
  # 1) Instrument has surveys but its record in Redis doesn't exist
  # 2) Instrument responses have changed since the last export
  def re_export?
    return false if instrument.surveys.blank?
    # return true if csv_blank?
    instrument.responses.maximum('updated_at') > updated_at
  end

  def done?(format)
    format && completion >= 100
  end

  private

  def csv_blank?
    wide_csv = $redis.get "#{instrument_id}-#{id}-wide"
    return true if JSON.parse(wide_csv).blank?
    long_csv = $redis.get "#{instrument_id}-#{id}-long"
    return true if JSON.parse(long_csv).blank?
    short_csv = $redis.get "#{instrument_id}-#{id}-short"
    return true if JSON.parse(short_csv).blank?
    false
  end

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
