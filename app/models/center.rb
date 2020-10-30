# frozen_string_literal: true

# == Schema Information
#
# Table name: centers
#
#  id             :bigint           not null, primary key
#  identifier     :string
#  name           :string
#  center_type    :string
#  administration :string
#  region         :string
#  department     :string
#  municipality   :string
#  score_data     :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Center < ApplicationRecord
  include Scoreable
  has_many :score_scheme_centers, dependent: :destroy
  has_many :score_schemes, through: :score_scheme_centers
  has_many :survey_scores, foreign_key: :identifier, primary_key: :identifier

  validates :identifier, presence: true, allow_blank: false
  validates :name, presence: true, allow_blank: false
  validates :center_type, presence: true, allow_blank: false

  default_scope { order :identifier }

  def score(survey_score, score_scheme)
    generate_score(score_scheme.score_units, survey_score.id, self)
  end

  def self.download(score_scheme)
    csv = []
    score_scheme.centers.sort_by { |c| c.identifier.to_i }.each do |center|
      css = center.survey_scores.where(score_scheme_id: score_scheme.id)
      if css.size > 1
        domain_scores = {}
        subdomain_scores = {}
        survey_ids = []
        cds = []
        css.each do |survey_score|
          next if survey_score.score_data.nil?

          survey_ids << survey_score.survey_id
          score_data = []
          JSON.parse(survey_score.score_data).each { |arr| score_data << arr }
          score_data.each do |row|
            next if row[12].blank?

            sd_scores = subdomain_scores[row[8]]
            sd_scores = [] if sd_scores.nil?
            sd_scores << row[12]
            subdomain_scores[row[8]] = sd_scores

            next if row[13].blank?

            d_scores = domain_scores[row[7]]
            d_scores = [] if d_scores.nil?
            d_scores << row[13]
            domain_scores[row[7]] = d_scores
          end
        end
        score_scheme.domains.sort_by { |domain| domain.title.to_i }.each_with_index do |domain, d_index|
          ds = domain_scores[domain.title]
          domain.subdomains.each_with_index do |subdomain, sd_index|
            sds = subdomain_scores[subdomain.title]
            subdomain_score = sds.inject(0.0) { |sum, item| sum + item } / sds.size if sds
            domain_score = ds.inject(0.0) { |sum, item| sum + item } / ds.size if ds && sd_index == domain.subdomains.size - 1
            cds << domain_score if domain_score
            center_score = cds.inject(0.0) { |sum, item| sum + item } / cds.size if d_index == score_scheme.domains.size - 1 && sd_index == domain.subdomains.size - 1

            csv << [center.identifier, center.center_type, center.administration,
                    center.region, center.department, center.municipality,
                    survey_ids.join('-'), domain.title, subdomain.title,
                    subdomain_score.nil? ? '' : subdomain_score.round(2),
                    domain_score.nil? ? '' : domain_score.round(2),
                    center_score.nil? ? '' : center_score.round(2)]
          end
        end
      elsif css.size == 1
        unless css[0].score_data.nil?
          score_data = []
          JSON.parse(css[0].score_data).each { |arr| score_data << arr }
          score_data.each do |row|
            next if row[12].blank? && row[13].blank? && row[14].blank?

            csv << [center.identifier, center.center_type, center.administration,
                    center.region, center.department, center.municipality,
                    row[0], row[7], row[8], row[12], row[13], row[14]]
          end
        end
      end
    end
    file = Tempfile.new("center-scores-#{score_scheme.title}")
    CSV.open(file, 'w') do |row|
      row << %w[center_id center_type center_admin region department municipality
                survey_ids domain subdomain subdomain_score domain_score center_score]
      csv.each do |data|
        row << data
      end
    end
    file
  end
end
