# == Schema Information
#
# Table name: response_exports
#
#  id                  :integer          not null, primary key
#  long_format_url     :string(255)
#  long_done           :boolean          default(FALSE)
#  created_at          :datetime
#  updated_at          :datetime
#  project_id          :integer
#  instrument_id       :integer
#  instrument_versions :text
#  wide_format_url     :string(255)
#  wide_done           :boolean          default(FALSE)
#  short_format_url    :string(255)
#  short_done          :boolean          default(FALSE)
#

class ResponseExport < ActiveRecord::Base
  serialize :instrument_versions
  belongs_to :project
  belongs_to :instrument
  has_one :response_images_export, dependent: :destroy
  before_destroy :destroy_files

  def percent_complete(model)
    total_surveys = model.surveys.where('surveys.created_at < ?', created_at).count * 3.0
    remaining_surveys = instrument.get_export_count(id.to_s).to_i
    if remaining_surveys > 0
      percent = ((total_surveys - remaining_surveys.to_f) / total_surveys) * 100
      percent = percent.round
    else
      percent = 100
    end
    if percent >= 100 && !wide_done && !short_done && !long_done
      update_columns(short_done: true, long_done: true, wide_done: true)
    end
    percent
  end

  private

  def destroy_files
    File.delete(long_format_url) if long_format_url && File.exist?(long_format_url)
    File.delete(wide_format_url) if wide_format_url && File.exist?(wide_format_url)
    File.delete(short_format_url) if short_format_url && File.exist?(short_format_url)
  end
end
