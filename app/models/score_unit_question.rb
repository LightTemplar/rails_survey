# frozen_string_literal: true

# == Schema Information
#
# Table name: score_unit_questions
#
#  id                     :integer          not null, primary key
#  score_unit_id          :integer
#  instrument_question_id :integer
#  created_at             :datetime
#  updated_at             :datetime
#  deleted_at             :datetime
#

class ScoreUnitQuestion < ApplicationRecord
  belongs_to :score_unit
  belongs_to :instrument_question
  has_many :option_scores, dependent: :destroy

  acts_as_paranoid

  validates :score_unit_id, presence: true, allow_blank: false
  validates :instrument_question_id, presence: true, uniqueness: { scope: [:score_unit_id] }

  def question_identifier
    instrument_question.identifier
  end

  def response(survey)
    survey.responses.where(question_identifier: instrument_question.identifier).first
  end

  def option(response)
    instrument_question.all_non_special_options[response.text.to_i] unless response&.text.blank?
  end

  def option_identifiers(response)
    identifiers = []
    if instrument_question.list_of_boxes_variant?
      response.text.split(',').each_with_index do |text, index|
        identifiers << instrument_question.all_non_special_options[index]&.identifier unless text.blank?
      end
    else
      response.text.split(',').each do |text|
        identifiers << instrument_question.all_non_special_options[text&.to_i]&.identifier unless text.blank?
      end
    end
    identifiers
  end

  def option_index(option)
    instrument_question.all_non_special_options.index(option)
  end

  def option_score(option)
    option_scores.where(option_identifier: option.identifier).first
  end
end
