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
      question = unit.questions.first # TODO: What about the other questions
      response = survey.response(question) # TODO why?
      option = survey.option(question)
      option_score = unit.option_scores.where(option_id: option.id).try(:first)
      unit_raw_score.update(value: option_score.value)
      puts unit_raw_score.inspect
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
end
