# frozen_string_literal: true

# == Schema Information
#
# Table name: survey_scores
#
#  id              :integer          not null, primary key
#  survey_id       :integer
#  score_scheme_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#  uuid            :string
#  survey_uuid     :string
#  device_uuid     :string
#  device_label    :string
#  deleted_at      :datetime
#  identifier      :string
#

class SurveyScore < ApplicationRecord
  include Scoreable
  belongs_to :score_scheme
  belongs_to :survey
  has_many :raw_scores
  has_many :domains, through: :score_scheme
  has_many :subdomains, through: :domains
  has_many :score_units, through: :subdomains
  has_many :score_data, dependent: :destroy
  has_many :domain_scores, through: :score_data
  has_many :subdomain_scores, through: :score_data

  acts_as_paranoid

  def nullify_scores
    default_score_datum.domain_scores.update_all(score_sum: nil)
    default_score_datum.subdomain_scores.update_all(score_sum: nil)
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

  def download_headers
    %w[survey_id center_id center_type center_admin region department municipality
       domain subdomain score_unit score_unit_weight score_unit_score subdomain_score
       domain_score center_score response response_label_en response_label_es]
  end

  def download_scores
    weights = score_data.pluck(:weight).uniq
    files = {}
    weights.each do |weight|
      filename = "#{identifier}_#{weight}.csv"
      file = Tempfile.new(filename)
      CSV.open(file, 'w') do |csv|
        csv << download_headers
        score_data.where(weight: weight).each do |score_datum|
          next if score_datum.content.nil?

          data = []
          JSON.parse(score_datum.content).each { |arr| data << arr }
          data.each do |row|
            csv << row
          end
        end
      end
      files[filename] = file
    end

    zip_file = Tempfile.new("#{identifier}_#{Time.now.to_i}.zip")
    Zip::File.open(zip_file, Zip::File::CREATE) do |zipfile|
      files.each do |filename, file|
        zipfile.add(filename, file.path)
      end
    end
    zip_file
  end

  def save_scores
    score_datum = default_score_datum
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
        subdomain_score = subdomain.default_subdomain_score(score_datum)&.score_sum
        domain_score = domain.default_domain_score(score_datum)&.score_sum if index == domain.subdomains.size - 1
        center_score = score_datum.score_sum if d_index == domains.size - 1 && index == domain.subdomains.size - 1
        sd_score = subdomain_score.nil? || subdomain_score.nan? ? '' : subdomain_score
        d_score = domain_score.nil? || domain_score.nan? ? '' : domain_score
        c_score = center_score.nil? || center_score.nan? ? '' : center_score

        csv << [survey.id, identifier, ctr&.center_type, ctr&.administration,
                ctr&.region, ctr&.department, ctr&.municipality, domain.title,
                subdomain.title, '', '', '', sd_score, d_score, c_score, '', '', '']
      end
    end
    score_datum.update_attributes(content: csv.to_s)
  end

  def center
    score_scheme.centers.find_by(identifier: identifier)
  end

  def sanitized_raw_scores
    raw_scores.where.not(value: nil)
  end

  def default_score_datum
    score_datum = score_data.where(operator: nil, weight: nil).first
    score_datum ||= ScoreDatum.create(survey_score_id: id)
  end

  def score(srs)
    score_sum = generate_score(score_scheme.distinct_score_units, srs)
    score_datum = default_score_datum
    score_datum.update_attributes(score_sum: score_sum)
  end

  def generate_score_data(score_datum)
    csv = []
    srs = sanitized_raw_scores
    ctr = center
    domains.sort_by { |domain| domain.title.to_i }.each_with_index do |domain, d_index|
      domain.subdomains.sort_by { |sd| sd.title.to_f }.each_with_index do |subdomain, index|
        s_units = subdomain.score_units.where('score_units.weight >= ?', score_datum.weight)
        s_units.sort_by { |su| [su.str_title, su.int_title] }.each do |score_unit|
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
        subdomain_score = subdomain.generate_score(s_units, srs)
        score_datum.update_subdomain_score(subdomain, subdomain_score)
        if index == domain.subdomains.size - 1
          d_units = domain.score_units.where('score_units.weight >= ?', score_datum.weight)
          domain_score = domain.generate_score(d_units, srs)
          score_datum.update_domain_score(domain, domain_score)
        end
        if d_index == domains.size - 1 && index == domain.subdomains.size - 1
          c_units = score_units.where('score_units.weight >= ?', score_datum.weight)
          center_score = ctr.generate_score(c_units, srs)
          score_datum.update_columns(score_sum: center_score)
        end
        sd_score = subdomain_score.nil? || subdomain_score.nan? ? '' : subdomain_score
        d_score = domain_score.nil? || domain_score.nan? ? '' : domain_score
        c_score = center_score.nil? || center_score.nan? ? '' : center_score

        csv << [survey.id, identifier, ctr&.center_type, ctr&.administration,
                ctr&.region, ctr&.department, ctr&.municipality, domain.title,
                subdomain.title, '', '', '', sd_score, d_score, c_score, '', '', '']
      end
    end
    score_datum.update_attributes(content: csv.to_s)
  end
end
