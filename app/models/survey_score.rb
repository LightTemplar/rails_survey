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
  include Scoreable
  belongs_to :score_scheme
  belongs_to :survey
  has_many :raw_scores
  has_many :domain_scores
  has_many :subdomain_scores
  has_many :domains, through: :score_scheme
  has_many :subdomains, through: :domains
  has_many :score_units, through: :subdomains

  acts_as_paranoid

  def nullify_scores
    domain_scores.update_all(score_sum: nil)
    subdomain_scores.update_all(score_sum: nil)
    raw_scores.update_all(value: nil)
  end

  def instrument_id
    survey.instrument_id
  end

  def instrument_title
    survey.instrument_title
  end

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

  def generate_raw_scores
    ScoreGeneratorWorker.perform_async(score_scheme_id, survey_id)
  end

  def download
    file = Tempfile.new(title.to_s)
    CSV.open(file, 'w') do |csv|
      csv << %w[survey_id center_id center_type center_admin region department
                municipality domain subdomain score_unit score_unit_weight
                score_unit_score subdomain_score domain_score center_score
                response response_label_en response_label_es]
      unless score_data.nil?
        data = []
        JSON.parse(score_data).each { |arr| data << arr }
        data.each do |row|
          csv << row
        end
      end
    end
    file
  end

  def save_scores
    ctr = center
    csv = []
    domains.sort_by { |domain| domain.title.to_i }.each_with_index do |domain, d_index|
      domain.subdomains.sort_by { |sd| sd.title.to_f }.each_with_index do |subdomain, index|
        subdomain.score_units.sort_by { |su| [su.str_title, su.int_title] }.each do |score_unit|
          raw_scores.where(score_unit_id: score_unit.id).each do |raw_score|
            rs = raw_score.value.nil? || raw_score.value.nan? ? '' : raw_score.value
            csv << [survey.id, identifier, ctr&.center_type, ctr&.administration,
                    ctr&.region, ctr&.department, ctr&.municipality, domain.title,
                    subdomain.title, score_unit.title, raw_score.weight, rs,
                    '', '', '', raw_score.response.nil? ? '' : raw_score.response&.text,
                    raw_score.response.nil? ? '' : raw_score.response&.to_s,
                    raw_score.response.nil? ? '' : raw_score.response&.to_s_es]
          end
        end
        subdomain_score = subdomain_scores.where(subdomain_id: subdomain.id).first&.score_sum
        domain_score = domain_scores.where(domain_id: domain.id).first&.score_sum if index == domain.subdomains.size - 1
        center_score = score_sum if d_index == domains.size - 1 && index == domain.subdomains.size - 1
        sd_score = subdomain_score.nil? || subdomain_score.nan? ? '' : subdomain_score
        d_score = domain_score.nil? || domain_score.nan? ? '' : domain_score
        c_score = center_score.nil? || center_score.nan? ? '' : center_score

        csv << [survey.id, identifier, ctr&.center_type, ctr&.administration,
                ctr&.region, ctr&.department, ctr&.municipality, domain.title,
                subdomain.title, '', '', '', sd_score, d_score, c_score, '', '', '']
      end
    end
    update_columns(score_data: csv.to_s)
  end

  def center
    score_scheme.centers.find_by(identifier: identifier)
  end

  def sanitized_raw_scores
    raw_scores.where.not(value: nil)
  end

  def score(srs)
    update_columns(score_sum: generate_score(score_scheme.distinct_score_units, srs))
  end
end
