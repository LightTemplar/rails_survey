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
    domain_scores = []
    center_score = nil
    type = category = ''
    type = survey.center_name&.split('(').last&.split(')')&.first if survey.center_name.include? '('
    category = survey.center_name&.split('-').last if survey.center_name.include? '-'
    domains.each_with_index do |domain, d_index|
      subdomain_scores = []
      domain.subdomains.each_with_index do |subdomain, index|
        subdomain_score = subdomain.score(survey_score)
        subdomain_scores << subdomain_score if subdomain_score
        subdomain.score_units.each do |score_unit|
          score_unit.survey_raw_scores(survey_score).each do |raw_score|
            next unless raw_score.value

            csv << [survey.id, survey.center_identifier, type, category, survey.identifier, domain.title,
                    subdomain.title, score_unit.title, score_unit.weight, raw_score.value, '', '', '']
          end
        end
        domain_score = subdomain_scores.inject(0.0) { |sum, item| sum + item } / subdomain_scores.size if index == domain.subdomains.size - 1
        domain_scores << domain_score if domain_score && !domain_score.nan?
        center_score = domain_scores.inject(0.0) { |sum, item| sum + item } / domain_scores.size if d_index == domains.size - 1 && index == domain.subdomains.size - 1
        csv << ['', '', '', '', survey.identifier, '', '', '', '', '',
                subdomain_score.nil? ? '' : subdomain_score,
                domain_score.nil? || domain_score.nan? ? '' : domain_score.round(2),
                center_score.nil? || center_score.nan? ? '' : center_score.round(2)]
      end
    end
    survey_score.score_data = csv.to_s
    survey_score.score_sum = center_score.round(2)
    survey_score.save
  end

  def download
    file = Tempfile.new(title.to_s)
    CSV.open(file, 'w') do |csv|
      csv << %w[survey_id center_id center_type center_category center_code domain subdomain score_unit
                score_unit_weight score_unit_score subdomain_score domain_score center_score]
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
