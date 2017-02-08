# == Schema Information
#
# Table name: raw_scores
#
#  id            :integer          not null, primary key
#  score_unit_id :integer
#  score_id      :integer
#  value         :float
#  created_at    :datetime
#  updated_at    :datetime
#

class RawScore < ActiveRecord::Base
  belongs_to :score_unit
  belongs_to :score

  def question_identifiers
    score_unit.questions.pluck(:question_identifier).join(', ')
  end

  def response_texts
    responses = []
    score_unit.questions.each do |question|
      responses << score.survey.response_for_question(question).try(:text)
    end
    responses.join(', ')
  end
end
