# frozen_string_literal: true

# == Schema Information
#
# Table name: subdomain_scores
#
#  id              :bigint           not null, primary key
#  subdomain_id    :integer
#  survey_score_id :integer
#  score_sum       :float
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class SubdomainScore < ApplicationRecord
  belongs_to :subdomain
  belongs_to :survey_score

  validates :subdomain_id, presence: true, allow_blank: false, uniqueness: { scope: [:survey_score_id] }
end
