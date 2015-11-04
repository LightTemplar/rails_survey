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
#

class Response < ActiveRecord::Base
  belongs_to :question
  belongs_to :survey, foreign_key: :survey_uuid, primary_key: :uuid
  delegate :device, to: :survey 
  delegate :instrument, to: :survey
  delegate :project, to: :survey
  delegate :instrument_version_number, to: :survey
  delegate :instrument_version, to: :survey
  has_one :response_image, foreign_key: :response_uuid, primary_key: :uuid
  belongs_to :device_user
  acts_as_paranoid
  validate :question_existence
  validates :survey, presence: true
  after_destroy :calculate_response_rate
  after_create {|response| response.message }

  def question_existence
    unless Question.with_deleted.find_by_id(question_id)
      errors.add(:question, 'has never existed')
    end
  end
  
  def calculate_response_rate
    SurveyPercentWorker.perform_in(30.minutes, survey.id)
  end

  def to_s
    if question.nil? or question.options.empty?
      text
    else
      question.options[text.to_i].to_s
    end
  end

  def grouped_responses
    self.group(:created_at)
  end

  def time_taken_in_seconds
    if time_ended && time_started
      time_ended - time_started
    end
  end

  def option_labels
    labels = [] 
    if question and versioned_question and versioned_question.has_options? 
      text.split(Settings.list_delimiter).each do |option_index|
        if versioned_question.has_other? and option_index.to_i == versioned_question.other_index
          labels << 'Other'
        else
          labels << versioned_question.options[option_index.to_i].to_s
        end
      end
    end
    labels.join(Settings.list_delimiter)
  end

  def dictionary
    labels = [] 
    if question and question.has_options?
      question.options.with_deleted.each_with_index do |option, index|
        labels << "#{index}=\"#{option}\""
      end
      labels << "#{question.other_index}=\"Other\"" if question.has_other?
    end
    labels.join(Settings.dictionary_delimiter)
  end

  def versioned_question
    @versioned_question ||= instrument_version.find_question_by(question_identifier: question_identifier)
  end
  
  def message
    msg =  { count: Response.count }
    begin
      $redis.publish 'responses-create', msg.to_json
    rescue Errno::ECONNREFUSED
      logger.debug 'Redis is not running'
    end
  end
end
