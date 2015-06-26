# == Schema Information
#
# Table name: survey_scores
#
#  id                :integer          not null, primary key
#  created_at        :datetime
#  updated_at        :datetime
#  survey_id         :integer
#  survey_uuid       :string(255)
#  device_label      :string(255)
#  device_user       :string(255)
#  survey_start_time :string(255)
#  survey_end_time   :string(255)
#  center_id         :string(255)
#

class SurveyScore < ActiveRecord::Base
  attr_accessible :survey_id, :survey_uuid, :device_label, :device_user, :survey_start_time, :survey_end_time, :center_id
  has_many :unit_scores, dependent: :destroy
  has_many :units, through: :unit_scores
end
