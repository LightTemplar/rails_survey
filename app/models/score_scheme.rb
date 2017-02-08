# == Schema Information
#
# Table name: score_schemes
#
#  id            :integer          not null, primary key
#  instrument_id :string(255)
#  title         :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

class ScoreScheme < ActiveRecord::Base
  belongs_to :instrument
  has_many :score_units, dependent: :destroy
  has_many :scores, dependent: :destroy
  validates :title, presence: true, allow_blank: false

  def score_survey(survey)
    score = get_score(survey)
    score_units.each do |unit|
      unit_raw_score = get_raw_score(score, unit)
      assign_unit_scores(survey, unit, unit_raw_score)
    end
  end

  def get_score(survey)
    score = scores.where(survey_id: survey.id).try(:first)
    unless score
      score = scores.create(survey_id: survey.id, score_scheme_id: id)
    end
    score
  end

  def get_raw_score(score, unit)
    raw_score = score.raw_scores.where(score_unit_id: unit.id).try(:first)
    unless raw_score
      raw_score = score.raw_scores.create(score_unit_id: unit.id, score_id: score.id)
    end
    raw_score
  end

  def option_at_index(question, response)
    question.non_special_options[response.text.to_i]
  end

  def assign_unit_scores(survey, unit, unit_raw_score)
    if unit.question_type == 'SELECT_ONE' || unit.question_type == 'SELECT_ONE_WRITE_OTHER'
      score_single_select(survey, unit, unit_raw_score)
    elsif unit.question_type == 'SELECT_MULTIPLE'
      # TODO: Implement
    end
  end

  def score_single_select(survey, unit, unit_raw_score)
    selected_options = []
    unit.questions.each do |question|
      response = survey.response_for_question(question)
      next unless response
      option = option_at_index(question, response)
      selected_options << unit.option_scores.where(option_id: option.id).try(:first)
    end
    option_score = selected_options.max_by(&:value)
    unit_raw_score.update(value: option_score.value) if option_score
  end
end
