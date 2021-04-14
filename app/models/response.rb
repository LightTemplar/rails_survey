# frozen_string_literal: true

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
#  survey_uuid         :string
#  special_response    :string
#  time_started        :datetime
#  time_ended          :datetime
#  question_identifier :string
#  uuid                :string
#  device_user_id      :integer
#  question_version    :integer          default(-1)
#  deleted_at          :datetime
#  randomized_data     :text
#  rank_order          :string
#  other_text          :text
#

require 'sidekiq/api'

class Response < ApplicationRecord
  include Sanitizer
  attribute :uuid, :string, default: -> { SecureRandom.uuid }
  belongs_to :instrument_question, foreign_key: :question_identifier, primary_key: :identifier
  belongs_to :survey, foreign_key: :survey_uuid, primary_key: :uuid, touch: true
  belongs_to :device_user
  has_one :response_image, foreign_key: :response_uuid, primary_key: :uuid
  has_many :red_flags, through: :instrument_question

  delegate :device, to: :survey
  delegate :instrument, to: :survey
  delegate :project, to: :survey
  delegate :instrument_version_number, to: :survey
  delegate :instrument_version, to: :survey

  acts_as_paranoid
  has_paper_trail on: %i[update destroy]

  validates :uuid, presence: true, allow_blank: false, uniqueness: true

  after_destroy :calculate_response_rate

  def question
    quest = if instrument_question
              instrument_question.question
            else
              survey.question_by_identifier(question_identifier)
            end
    quest ||= InstrumentQuestion.find(question_id)&.question
  end

  def calculate_response_rate
    job = Sidekiq::ScheduledSet.new.find do |entry|
      entry.item['class'] == 'SurveyPercentWorker' && entry.item['args'].first == survey.id
    end
    SurveyPercentWorker.perform_in(30.minutes, survey.id) unless job
  end

  def to_s
    return text if instrument_question.nil? || instrument_question.non_special_options.empty?

    labels = []
    if instrument_question.list_of_boxes_variant?
      labels << instrument_question.non_special_options.map { |o| full_sanitizer.sanitize o.text }
    else
      text.split(Settings.list_delimiter).each do |option_index|
        labels << if instrument_question.other? && option_index.to_i == instrument_question.other_index
                    'Other'
                  else
                    full_sanitizer.sanitize instrument_question.non_special_options[option_index.to_i].to_s
                  end
      end
    end
    labels.join(Settings.list_delimiter)
  end

  def to_s_es
    return text if instrument_question.nil? || instrument_question.non_special_options.empty?

    labels = []
    if instrument_question.list_of_boxes_variant?
      labels << instrument_question.non_special_options.map { |o| full_sanitizer.sanitize o.translations.find_by_language('es')&.text }
    else
      text.split(Settings.list_delimiter).each do |option_index|
        labels << if instrument_question.other? && option_index.to_i == instrument_question.other_index
                    'Otro'
                  else
                    full_sanitizer.sanitize instrument_question.non_special_options[option_index.to_i].translations.find_by_language('es')&.text
                  end
      end
    end
    labels.join(Settings.list_delimiter)
  end

  def label_text(versioned_question, option_index)
    versioned_question.options[option_index.to_i].try(:text)
  end

  def grouped_responses
    group(:created_at)
  end

  def time_taken_in_seconds
    time_ended - time_started if time_ended && time_started
  end

  def is_critical
    if question.nil?
      false
    elsif !question.select_one_variant? && !question.select_multiple_variant? && !question.list_of_boxes_variant?
      false
    elsif text.blank?
      false
    else
      resps = text.split(Settings.list_delimiter)
      options = question.options
      response_identifiers = []
      resps.each do |ind|
        option = options[ind.to_i]
        response_identifiers.push(option.identifier) if option
      end
      identifiers = question.critical_responses.pluck(:option_identifier)
      !(response_identifiers & identifiers).empty? # Array intersection
    end
  end

  def empty?
    text.blank? && other_response.blank? && special_response.blank? && other_text.blank?
  end

  def is_red_flag?(score_scheme)
    if question.question_identifier == 'cts7'
      cts7_all = text.split(',').inject(0.0) { |sum, ans| sum + ans.to_i }
      cts8 = survey.responses.where(question_identifier: 'cts8').first
      cts8_all = cts8.text.split(',').inject(0.0) { |sum, ans| sum + ans.to_i }
      sdm1 = survey.responses.where(question_identifier: 'sdm1').first
      sdm1_a = sdm1.text.split(',')[0].to_f
      return (cts7_all + cts8_all / sdm1_a) > 20
    elsif question.question_identifier == 'cts8'
      cts8_all = text.split(',').inject(0.0) { |sum, ans| sum + ans.to_i }
      cts7 = survey.responses.where(question_identifier: 'cts7').first
      cts7_all = cts7.text.split(',').inject(0.0) { |sum, ans| sum + ans.to_i }
      sdm1 = survey.responses.where(question_identifier: 'sdm1').first
      sdm1_a = sdm1.text.split(',')[0].to_f
      return (cts7_all + cts8_all / sdm1_a) > 20
    elsif question.question_identifier == 'sdm6'
      l_array = text.split(',')
      l_count = l_array[0].to_f + l_array[2].to_f
      total_response = survey.responses.where(question_identifier: 'sdm1').first
      return false if total_response.nil? || total_response.text.blank?

      t_array = total_response.text.split(',')
      t_count = t_array[0].to_f + t_array[2].to_f
      rate = l_count / t_count
      return rate > 0.25
    elsif question.question_identifier == 'cts5'
      cts5a = text.split(',')[0].to_i
      cts4 = survey.responses.where(question_identifier: 'cts4').first.text.to_i
      return cts5a > cts4
    elsif question.question_identifier == 'cts6'
      cts6a = text.split(',')[0].to_f
      cts4 = survey.responses.where(question_identifier: 'cts4').first.text.to_i
      return (cts6a / cts4) > 1.5
    end

    rff = red_flags.where(score_scheme_id: score_scheme.id).where(selected: false)
    if text.blank?
      return true unless rff.empty?

      return false
    end

    unless rff.empty?
      rfi = rff.pluck(:option_identifier)
      roi = response_options.map(&:identifier)
      rfi.each do |rf|
        return true unless roi.include?(rf)
      end
    end

    nso = question.options
    red_flag_ids = red_flags.where(score_scheme_id: score_scheme.id).pluck(:option_identifier)
    response_options.each do |ro|
      is_rf = ro && red_flag_ids.include?(ro.identifier)
      if is_rf && question.question_identifier == 'ltc12' # takes care of (f) & (g)
        index = nso.index(ro)
        return text.split(',')[index].to_i > 0
      elsif is_rf && question.question_identifier == 'sdm1'
        index = nso.index(ro)
        return text.split(',')[index].to_i == 0
      end
      return true if is_rf
    end
    false
  end

  def response_options
    nso = question.options
    return [] if text.blank? || nso.empty?

    if question.list_of_boxes_variant?
      options = []
      text.split(',').each_with_index do |_r_text, index|
        options << nso[index]
      end
      return options
    end
    text.split(',').map { |index| nso[index.to_i] }
  end

  def red_flag_response_options(score_scheme)
    rfro = []
    nso = question.options
    rfs = red_flags.where(score_scheme_id: score_scheme.id)
    rff = rfs.where(selected: false).pluck(:option_identifier)
    unless rff.empty?
      roi = response_options.map(&:identifier)
      rff.each do |rf|
        next unless rf && !roi.include?(rf)

        op = nso.select { |ro| ro.identifier == rf }.first
        rfro << op if op
      end
    end
    red_flag_ids = rfs.pluck(:option_identifier) - rff
    response_options.each do |ro|
      is_rf = ro && red_flag_ids.include?(ro.identifier)
      if is_rf && question.question_identifier == 'ltc12'
        index = nso.index(ro)
        rfro << ro if text.split(',')[index].to_i > 0
      elsif is_rf && question.question_identifier == 'sdm1'
        index = nso.index(ro)
        rfro << ro if text.split(',')[index].to_i == 0
      end
      rfro << ro if is_rf
    end
    rfro
  end

  def red_flag_descriptions(score_scheme)
    identifiers = red_flag_response_options(score_scheme).pluck(:identifier)
    red_flags.where(score_scheme_id: score_scheme.id).where(option_identifier: identifiers).map(&:description).uniq.join(', ')
  end

  def red_flag_response(score_scheme)
    red_flag_response_options(score_scheme).map(&:text).uniq.join(', ')
  end
end
