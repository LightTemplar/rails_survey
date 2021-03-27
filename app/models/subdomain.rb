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
  has_many :subdomain_scores, dependent: :destroy
  has_many :translations, foreign_key: 'subdomain_id', class_name: 'SubdomainTranslation', dependent: :destroy
  delegate :score_scheme, to: :domain

  acts_as_paranoid

  validates :title, presence: true, allow_blank: false, uniqueness: { scope: [:domain_id] }

  default_scope { order(:title) }

  def title_name
    "#{title} #{name}"
  end

  def translated_title_name(language)
    translations.where(language: language)
                .reject { |dt| dt.text.blank? }
                .map { |dt| "#{title} #{dt.text}" }
                .join(' | ')
  end

  def translated_name(language)
    tname = translations.where(language: language)
                        .reject { |dt| dt.text.blank? }
                        .map(&:text)
                        .first
    tname.blank? ? name : tname
  end

  def default_subdomain_score(default_score_datum)
    subdomain_score = subdomain_scores.where(score_datum_id: default_score_datum.id).first
    subdomain_score ||= SubdomainScore.create(subdomain_id: id, score_datum_id: default_score_datum.id)
  end

  def score(survey_score, srs)
    score_sum = generate_score(score_units, srs)
    subdomain_score = default_subdomain_score(survey_score.default_score_datum)
    subdomain_score.update_columns(score_sum: score_sum)
    score_sum
  end
end
