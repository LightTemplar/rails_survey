# frozen_string_literal: true

# == Schema Information
#
# Table name: domains
#
#  id              :integer          not null, primary key
#  title           :string
#  score_scheme_id :integer
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  weight          :float
#  name            :string
#

class Domain < ApplicationRecord
  include Scoreable
  belongs_to :score_scheme
  has_many :subdomains, dependent: :destroy
  has_many :raw_scores, through: :subdomains
  has_many :score_units, through: :subdomains
  has_many :domain_scores, dependent: :destroy
  has_many :subdomain_scores, through: :subdomains
  has_many :translations, foreign_key: 'domain_id', class_name: 'DomainTranslation', dependent: :destroy
  has_many :subdomain_translations, through: :subdomains, source: :translations

  acts_as_paranoid

  validates :title, presence: true, allow_blank: false, uniqueness: { scope: [:score_scheme_id] }

  def distinct_score_units
    by_title = score_units.group_by(&:title)
    unique_units = []
    by_title.each do |_title, score_unit|
      unique_units << score_unit[0]
    end
    unique_units
  end

  def default_domain_score(default_score_datum)
    domain_score = domain_scores.where(score_datum_id: default_score_datum.id).first
    domain_score ||= DomainScore.create(domain_id: id, score_datum_id: default_score_datum.id)
  end

  def score(survey_score, srs)
    score_sum = generate_score(distinct_score_units, srs)
    domain_score = default_domain_score(survey_score.default_score_datum)
    domain_score.update_columns(score_sum: score_sum)
    score_sum
  end

  def title_name
    "#{title} #{name}"
  end

  def translated_title_name(language)
    translations.where(language: language)
                .reject { |dt| dt.text.blank? }
                .map { |dt| "#{title} #{dt.text}" }
                .join(' | ')
  end
end
