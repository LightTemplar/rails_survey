# frozen_string_literal: true

# == Schema Information
#
# Table name: score_schemes
#
#  id            :integer          not null, primary key
#  instrument_id :integer
#  title         :string
#  created_at    :datetime
#  updated_at    :datetime
#  deleted_at    :datetime
#  active        :boolean
#

class ScoreScheme < ApplicationRecord
  belongs_to :instrument
  has_many :surveys, through: :instrument
  has_many :domains, dependent: :destroy
  has_many :subdomains, through: :domains
  has_many :score_units, through: :subdomains
  has_many :score_unit_questions, through: :score_units
  has_many :option_scores, through: :score_unit_questions
  has_many :survey_scores
  has_many :centers

  delegate :project, to: :instrument

  acts_as_paranoid

  validates :title, presence: true, uniqueness: { scope: [:instrument_id] }

  def score
    surveys.each do |survey|
      SurveyScoreWorker.perform_async(id, survey.id)
    end
  end

  def download_center_scores
    csv = []
    centers.each do |center|
      if center.survey_scores.size > 1
        domain_scores = {}
        subdomain_scores = {}
        survey_ids = []
        cds = []
        center.survey_scores.each do |survey_score|
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
        domains.each_with_index do |domain, d_index|
          ds = domain_scores[domain.title]
          domain.subdomains.each_with_index do |subdomain, sd_index|
            sds = subdomain_scores[subdomain.title]
            subdomain_score = sds.inject(0.0) { |sum, item| sum + item } / sds.size if sds
            domain_score = ds.inject(0.0) { |sum, item| sum + item } / ds.size if ds && sd_index == domain.subdomains.size - 1
            cds << domain_score if domain_score
            center_score = cds.inject(0.0) { |sum, item| sum + item } / cds.size if d_index == domains.size - 1 && sd_index == domain.subdomains.size - 1

            csv << [center.identifier, center.center_type, center.administration, center.region,
                    center.department, center.municipality, survey_ids.join('-'), domain.title, subdomain.title,
                    subdomain_score.nil? ? '' : subdomain_score.round(2),
                    domain_score.nil? ? '' : domain_score.round(2),
                    center_score.nil? ? '' : center_score.round(2)]
          end
        end
      elsif center.survey_scores.size == 1
        score_data = []
        JSON.parse(center.survey_scores[0].score_data).each { |arr| score_data << arr }
        score_data.each do |row|
          next if row[12].blank?

          csv << [center.identifier, center.center_type, center.administration, center.region,
                  center.department, center.municipality, row[0], row[7], row[8], row[12], row[13], row[14]]
        end
      end
    end
    file = Tempfile.new("center-scores-#{title}")
    CSV.open(file, 'w') do |row|
      row << %w[center_id center_type center_admin region department municipality
                survey_ids domain subdomain subdomain_score domain_score center_score]
      csv.each do |data|
        row << data
      end
    end
    file
  end

  def generate_raw_scores(survey, survey_score)
    score_units.each do |unit|
      raw_score = survey_score.raw_scores.where(score_unit_id: unit.id, survey_score_id: survey_score.id).first
      raw_score ||= RawScore.create(score_unit_id: unit.id, survey_score_id: survey_score.id)
      raw_score.value = unit.score(survey)
      raw_score.save
    end
    generate_score_data(survey, survey_score)
  end

  def generate_score_data(survey, survey_score)
    identifier = survey.identifier
    center = centers.find_by(identifier: identifier)
    csv = []
    domain_scores = []
    center_score = nil

    domains.each_with_index do |domain, d_index|
      subdomain_scores = []
      domain.subdomains.each_with_index do |subdomain, index|
        subdomain_score = subdomain.score(survey_score)
        subdomain_scores << subdomain_score if subdomain_score
        subdomain.score_units.each do |score_unit|
          score_unit.survey_raw_scores(survey_score).each do |raw_score|
            next unless raw_score.value

            csv << [survey.id, identifier, center.center_type, center.administration,
                    center.region, center.department, center.municipality, domain.title,
                    subdomain.title, score_unit.title, score_unit.weight, raw_score.value, '', '', '']
          end
        end
        domain_score = subdomain_scores.inject(0.0) { |sum, item| sum + item } / subdomain_scores.size if index == domain.subdomains.size - 1
        domain_scores << domain_score if domain_score && !domain_score.nan?
        center_score = domain_scores.inject(0.0) { |sum, item| sum + item } / domain_scores.size if d_index == domains.size - 1 && index == domain.subdomains.size - 1
        sd_score = subdomain_score.nil? ? '' : subdomain_score
        d_score = domain_score.nil? || domain_score.nan? ? '' : domain_score.round(2)
        c_score = center_score.nil? || center_score.nan? ? '' : center_score.round(2)
        next if sd_score.blank? && d_score.blank? && c_score.blank?

        csv << [survey.id, identifier, center.center_type, center.administration,
                center.region, center.department, center.municipality, domain.title,
                subdomain.title, '', '', '', sd_score, d_score, c_score]
      end
    end
    survey_score.score_data = csv.to_s
    survey_score.score_sum = center_score.round(2)
    survey_score.save
  end

  def download
    file = Tempfile.new(title.to_s)
    CSV.open(file, 'w') do |csv|
      csv << %w[survey_id center_id center_type center_admin region department
                municipality domain subdomain score_unit score_unit_weight
                score_unit_score subdomain_score domain_score center_score]
      survey_scores.each do |survey_score|
        data = []
        JSON.parse(survey_score.score_data).each { |arr| data << arr }
        data.each do |row|
          csv << row
        end
      end
    end
    file
  end
end
