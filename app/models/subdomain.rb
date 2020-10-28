# frozen_string_literal: true

# == Schema Information
#
# Table name: subdomains
#
#  id         :integer          not null, primary key
#  title      :string
#  domain_id  :integer
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  weight     :float
#  name       :string
#

class Subdomain < ApplicationRecord
  include Scoreable
  belongs_to :domain
  has_many :score_units, -> { order 'score_units.title' }, dependent: :destroy
  has_many :raw_scores, through: :score_units
  has_many :subdomain_scores
  delegate :score_scheme, to: :domain

  acts_as_paranoid

  validates :title, presence: true, allow_blank: false, uniqueness: { scope: [:domain_id] }

  default_scope { order(:title) }

  def score(survey_score)
    center = survey_score.center
    score_sum = generate_score(score_units, survey_score.id, center)
    subdomain_score = subdomain_scores.where(survey_score_id: survey_score.id).first
    if subdomain_score
      subdomain_score.update_columns(score_sum: score_sum)
    else
      SubdomainScore.create(subdomain_id: id, survey_score_id: survey_score.id, score_sum: score_sum)
    end
    score_sum
  end

  def title_name
    "#{title} #{name}"
  end
end
