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

  delegate :project, to: :instrument

  acts_as_paranoid

  validates :title, presence: true, uniqueness: { scope: [:instrument_id] }

  def score_unit_count
    score_units.size
  end

  def score_survey(survey)
    score = get_score(survey)
    score_units.each do |unit|
      scheme = SchemeGenerator.generate(unit)
      unit_raw_score = get_raw_score(score, unit)
      score_value = scheme.score(survey, unit)
      unit_raw_score.update(value: score_value)
    end
  end

  def get_score(survey)
    score = scores.where(survey_id: survey.id).try(:first)
    score ||= scores.create(survey_id: survey.id, score_scheme_id: id)
    score
  end

  def get_raw_score(score, unit)
    raw_score = score.raw_scores.where(score_unit_id: unit.id).try(:first)
    raw_score ||= score.raw_scores.create(score_unit_id: unit.id, score_id: score.id)
    raw_score
  end

  def score
    surveys.each do |survey|
      SurveyScoreWorker.perform_async(id, survey.id)
    end
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
    csv = []
    rss = survey_score.raw_score_sum
    wss = survey_score.weighted_score_sum
    wcss = 0
    domains.each do |domain|
      domain_score_sum = domain.score_sum(survey_score)
      domain_weighted_score_sum = domain.weighted_score_sum(survey_score)
      domain_score = domain.score(survey_score)
      domain.subdomains.each do |subdomain|
        subdomain_score_sum = subdomain.score_sum(survey_score)
        subdomain_weighted_score_sum = subdomain.weighted_score_sum(survey_score)
        subdomain_score = subdomain.score(survey_score)
        subdomain.score_units.each do |score_unit|
          score_unit.survey_raw_scores(survey_score).each do |raw_score|
            next unless raw_score.value

            csv << [survey.id, survey.uuid, survey.identifier, rss, wss, domain.title,
                    domain_score_sum, domain_weighted_score_sum, domain_score, subdomain.title,
                    subdomain_score_sum, subdomain_weighted_score_sum, subdomain_score,
                    score_unit.title, score_unit.weight, raw_score.value]
          end
        end
      end
    end
    survey_score.score_data = csv.to_s
    survey_score.save
  end

  def download
    file = Tempfile.new(title.to_s)
    CSV.open(file, 'w') do |csv|
      csv << %w[id uuid identifier raw_score_sum weighted_score_sum domain
                raw_domain_score weighted_domain_score domain_score subdomain
                raw_subdomain_score weighted_subdomain_score subdomain_score
                score_unit weight unit_raw_score]
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
