# == Schema Information
#
# Table name: responses
#
#  id                  :integer          not null, primary key
#  question_id         :integer
#  text                :text
#  other_response      :text
#  created_at          :datetime
#  updated_at          :datetime
#  survey_uuid         :string(255)
#  special_response    :string(255)
#  time_started        :datetime
#  time_ended          :datetime
#  question_identifier :string(255)
#  uuid                :string(255)
#  device_user_id      :integer
#  question_version    :integer          default(-1)
#  deleted_at          :datetime
#  randomized_data     :text
#

class Response < ActiveRecord::Base
  belongs_to :question
  belongs_to :survey, foreign_key: :survey_uuid, primary_key: :uuid, touch: true
  delegate :device, to: :survey
  delegate :instrument, to: :survey
  delegate :project, to: :survey
  delegate :instrument_version_number, to: :survey
  delegate :instrument_version, to: :survey
  has_one :response_image, foreign_key: :response_uuid, primary_key: :uuid
  belongs_to :device_user
  acts_as_paranoid
  has_paper_trail
  validate :question_existence
  validates :survey, presence: true
  after_destroy :calculate_response_rate

  def question_existence
    unless Question.with_deleted.find_by_id(question_id)
      errors.add(:question, 'has never existed')
    end
  end

  def calculate_response_rate
    SurveyPercentWorker.perform_in(30.minutes, survey.id)
  end

  def to_s
    if question.nil? || question.options.empty?
      text
    else
      question.options[text.to_i].to_s
    end
  end

  def grouped_responses
    group(:created_at)
  end

  def time_taken_in_seconds
    time_ended - time_started if time_ended && time_started
  end

  def randomized_data
    JSON.parse(read_attribute(:randomized_data)) unless read_attribute(:randomized_data).blank?
  end
end
