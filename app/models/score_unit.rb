# frozen_string_literal: true

# == Schema Information
#
# Table name: score_units
#
#  id           :integer          not null, primary key
#  weight       :float
#  created_at   :datetime
#  updated_at   :datetime
#  score_type   :string
#  deleted_at   :datetime
#  subdomain_id :integer
#  title        :string
#

class ScoreUnit < ActiveRecord::Base
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
end
