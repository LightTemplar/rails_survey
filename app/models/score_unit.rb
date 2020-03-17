# frozen_string_literal: true

# == Schema Information
#
# Table name: score_units
#
#  id               :integer          not null, primary key
#  weight           :float
#  created_at       :datetime
#  updated_at       :datetime
#  score_type       :string
#  deleted_at       :datetime
#  subdomain_id     :integer
#  title            :string
#  base_point_score :float
#

class ScoreUnit < ApplicationRecord
  belongs_to :subdomain
  has_many :score_unit_questions, dependent: :destroy
  has_many :option_scores, through: :score_unit_questions

  acts_as_paranoid

  validates :subdomain_id, presence: true, allow_blank: false
  validates :title, presence: true, uniqueness: { scope: [:subdomain_id] }

  def question_identifiers
    ids = score_unit_questions.map { |suq| suq.instrument_question.identifier }
    ids.join(',')
  end

  def option_score_count
    option_scores.size
  end

  def domain_id
    subdomain.domain_id
  end

  def copy
    new_copy = dup
    new_copy.title = "#{title}_copy"
    new_copy.save!
    score_unit_questions.each do |q|
      new_q = q.dup
      new_q.score_unit_id = new_copy.id
      new_q.save!
      q.option_scores.each do |os|
        new_os = os.dup
        new_os.score_unit_question_id = new_q.id
        new_os.save!
      end
    end
    new_copy
  end

  def score(survey)
    scores = []
    if score_type == 'MATCH'
      score_unit_questions.each do |suq|
        response = suq.response(survey)
        next unless response

        response_option = suq.option(response)
        next unless response_option

        option_score = option_scores.where(option_identifier: response_option.identifier).first
        scores << option_score if option_score
      end
    end
    scores.reject { |s| s.value.nil? }.max_by(&:value).try(:value)
  end
end
