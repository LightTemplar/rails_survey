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
      scores = get_unit_scores(survey, unit)
      update_raw_score(unit, unit_raw_score, scores)
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

  def option_at_index(question, index)
    question.non_special_options[index]
  end

  def get_unit_scores(survey, unit)
    scores = []
    unit.questions.each do |question|
      response = survey.response_for_question(question)
      next unless response
      if multiple_select?(unit)
        scores << get_scores_hash(unit).key(option_ids(question, response).sort)
      elsif single_select?(unit)
        option_id = option_ids(question, response)[0]
        scores << unit.option_scores.where(option_id: option_id).try(:first)
      end
    end
    scores.compact
  end

  def update_raw_score(unit, score, scores)
    if single_select?(unit)
      score.update(value: scores.max_by(&:value).try(:value)) unless scores.empty?
    elsif multiple_select?(unit)
      score.update(value: scores.max)
    end
  end

  def single_select?(unit)
    unit.question_type == 'SELECT_ONE' || unit.question_type == 'SELECT_ONE_WRITE_OTHER'
  end

  def multiple_select?(unit)
    unit.question_type == 'SELECT_MULTIPLE' || unit.question_type == 'SELECT_MULTIPLE_WRITE_OTHER'
  end

  def get_scores_hash(unit)
    scores_hash = {}
    unit.option_scores.all.group_by(&:value).each do |score, options|
      scores_hash[score] = options.map(&:option_id).sort
    end
    scores_hash
  end

  def option_ids(question, response)
    options = []
    response.try(:text).split(',').each do |text|
      options << option_at_index(question, text.to_i).try(:id)
    end
    options
  end
end
