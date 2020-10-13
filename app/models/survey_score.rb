# frozen_string_literal: true

# == Schema Information
#
# Table name: survey_scores
#
#  id              :integer          not null, primary key
#  survey_id       :integer
#  score_scheme_id :integer
#  score_sum       :float
#  created_at      :datetime
#  updated_at      :datetime
#  uuid            :string
#  survey_uuid     :string
#  device_uuid     :string
#  device_label    :string
#  deleted_at      :datetime
#  score_data      :text
#  identifier      :string
#

class SurveyScore < ApplicationRecord
  belongs_to :score_scheme
  belongs_to :survey
  has_many :raw_scores
  has_many :domains, through: :score_scheme

  acts_as_paranoid

  def title
    "#{score_scheme_id} - #{survey_id}"
  end

  def raw_score_sum
    raw_scores.sum(:value)
  end

  def weighted_score_sum
    raw_scores.inject(0) { |sum, item| sum + weighted_score(item) }
  end

  def weighted_score(raw_score)
    return 0 unless raw_score.value

    raw_score.value * raw_score.score_unit.weight
  end

  def score
    SurveyScoreWorker.perform_async(score_scheme_id, survey_id)
  end

  def download
    file = Tempfile.new(title.to_s)
    CSV.open(file, 'w') do |csv|
      csv << %w[survey_id center_id center_type center_admin region department
                municipality domain subdomain score_unit score_unit_weight
                score_unit_score subdomain_score domain_score center_score
                response response_label_en response_label_es]
      data = []
      JSON.parse(score_data).each { |arr| data << arr }
      data.each do |row|
        csv << row
      end
    end
    file
  end
end
