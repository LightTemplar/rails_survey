# frozen_string_literal: true

# == Schema Information
#
# Table name: domain_scores
#
#  id              :bigint           not null, primary key
#  domain_id       :integer
#  survey_score_id :integer
#  score_sum       :float
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class DomainScore < ApplicationRecord
  belongs_to :domain
  belongs_to :survey_score

  validates :domain_id, presence: true, allow_blank: false, uniqueness: { scope: [:survey_score_id] }
end
