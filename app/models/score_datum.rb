# frozen_string_literal: true

# == Schema Information
#
# Table name: score_data
#
#  id              :bigint           not null, primary key
#  content         :text
#  survey_score_id :integer
#  weight          :float
#  operator        :string
#  score_sum       :float
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class ScoreDatum < ApplicationRecord
  belongs_to :survey_score
  has_many :domain_scores, dependent: :destroy
  has_many :subdomain_scores, dependent: :destroy

  def update_subdomain_score(subdomain, score)
    sds = subdomain_scores.where(subdomain_id: subdomain.id).first
    sds ||= SubdomainScore.create(subdomain_id: subdomain.id, score_datum_id: id)
    sds.update_columns(score_sum: score)
  end

  def update_domain_score(domain, score)
    ds = domain_scores.where(domain_id: domain.id).first
    ds ||= DomainScore.create(domain_id: domain.id, score_datum_id: id)
    ds.update_columns(score_sum: score)
  end
end
