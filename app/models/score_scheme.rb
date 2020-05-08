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
  include Sanitizable
  belongs_to :instrument
  has_many :surveys, through: :instrument
  has_many :domains, dependent: :destroy
  has_many :subdomains, through: :domains
  has_many :score_units, through: :subdomains
  has_many :score_unit_questions, through: :score_units
  has_many :option_scores, through: :score_unit_questions
  has_many :survey_scores, -> { order 'identifier' }
  has_many :centers

  delegate :project, to: :instrument

  acts_as_paranoid

  validates :title, presence: true, uniqueness: { scope: [:instrument_id] }

  def export_file
    file = Tempfile.new(title)
    black = '000000'
    row_height = 30
    Axlsx::Package.new do |p|
      wb = p.workbook
      b_style = { style: :thin, color: black, edges: [:bottom] }
      wrap_text = { wrap_text: true }
      border = wb.styles.add_style(border: b_style)
      question_style = wb.styles.add_style(b: true, alignment: wrap_text)
      option_style = wb.styles.add_style(alignment: wrap_text)
      b_question_style = wb.styles.add_style(b: true, alignment: wrap_text, border: b_style)
      b_option_style = wb.styles.add_style(alignment: wrap_text, border: b_style)
      c_style = wb.styles.add_style(alignment: { horizontal: :center })
      c_border = wb.styles.add_style(alignment: { horizontal: :center }, border: b_style)
      domains.sort_by { |domain| domain.title.to_i }.each do |domain|
        wb.add_worksheet(name: "Domain #{domain.title}") do |sheet|
          tab_color = SecureRandom.hex(3)
          sheet.sheet_pr.tab_color = tab_color
          sheet.add_row ['', '', '', '', "#{domain.title}: #{domain.name}", '', '', '', '', ''],
                        style: wb.styles.add_style(b: true, alignment: { horizontal: :center, vertical: :center },
                                                   border: b_style, bg_color: tab_color), height: row_height
          sheet.add_row %w[Identifier Subdomain Weight Code Question Base Score Type Translation Notes],
                        style: wb.styles.add_style(alignment: { horizontal: :center, vertical: :center }, border: b_style),
                        height: row_height
          domain.subdomains.each do |subdomain|
            subdomain.score_units.sort_by { |su| [su.title_s, su.title_i] }.each do |unit|
              unit.score_unit_questions.each_with_index do |suq, index|
                q_style = index == unit.score_unit_questions.size - 1 && suq.option_scores.empty? ?
                [c_border, c_border, c_border, c_border, b_question_style, c_border, c_border, border,
                 b_question_style, b_option_style] : [c_style, c_style, c_style, c_style, question_style, c_style,
                                                      c_style, c_style, question_style, option_style]
                sheet.add_row [unit.title, subdomain.title, unit.weight, suq.question_identifier,
                               html_decode(full_sanitize(suq.instrument_question.text)),
                               unit.base_point_score == 0.0 ? '' : unit.base_point_score, '', unit.score_type,
                               full_sanitize(suq.instrument_question.translations.find_by_language('es')&.text),
                               html_decode(full_sanitize(unit.notes))], style: q_style
                sheet.column_widths nil, nil, nil, nil, 50, nil, nil, nil, 50, 50
                suq.option_scores.each_with_index do |score, index|
                  o_style = index == suq.option_scores.size - 1 ?
                  [border, border, border, c_border, b_option_style, border, c_border, c_border,
                   b_option_style, b_option_style] : [nil, nil, nil, c_style, option_style, nil,
                                                      c_style, c_style, option_style, option_style]
                  sheet.add_row ['', '', '', suq.option_index(score.option), full_sanitizer.sanitize(score.option.text),
                                 '', unit.score_type == 'SUM' ? "(#{format('%+0.1f', score.value)})" : score.value, '',
                                 full_sanitize(score.option.translations.find_by_language('es')&.text),
                                 html_decode(full_sanitize(score.notes))], style: o_style
                  sheet.column_widths nil, nil, nil, nil, 50, nil, nil, nil, 50, 50
                end
              end
            end
          end
        end
      end
      p.serialize(file.path)
    end
    file
  end

  def score
    surveys.each do |survey|
      SurveyScoreWorker.perform_async(id, survey.id)
    end
  end

  def download_center_scores
    csv = []
    centers.sort_by { |c| c.identifier.to_i }.each do |center|
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
        domains.sort_by { |domain| domain.title.to_i }.each_with_index do |domain, d_index|
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
          next if row[12].blank? && row[13].blank? && row[14].blank?

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

  def skip_grp1(unit, survey)
    quiz = unit.score_unit_questions.first&.instrument_question&.identifier
    return false if quiz != 'grp1'

    response1 = survey.responses.where(question_identifier: 'cts5').first
    count1 = response1.text.split(',').inject(0) { |sum, ans| sum + ans.to_i } if response1
    return true if count1 && count1 < 8

    response2 = survey.responses.where(question_identifier: 'cts6').first
    count2 = response2.text.split(',').inject(0) { |sum, ans| sum + ans.to_i } if response2
    count2.nil? ? true : count2 < 8
  end

  def generate_raw_scores(survey, survey_score)
    center = centers.find_by(identifier: survey.identifier)
    score_units.each do |unit|
      wrong_center_type = (unit.institution_type == 'RESIDENTIAL' && center.center_type != 'CDA') ||
                          (unit.institution_type == 'NON_RESIDENTIAL' &&
                            (center.center_type != 'CDI' || center.center_type != 'CBI'))
      next if wrong_center_type

      next if skip_grp1(unit, survey)

      raw_score = survey_score.raw_scores.where(score_unit_id: unit.id, survey_score_id: survey_score.id).first
      raw_score ||= RawScore.create(score_unit_id: unit.id, survey_score_id: survey_score.id)
      unit.generate_score(survey, raw_score)
    end
    generate_score_data(survey, survey_score)
  end

  def generate_score_data(survey, survey_score)
    identifier = survey.identifier
    center = centers.find_by(identifier: identifier)
    csv = []
    center_score = nil
    domains.sort_by { |domain| domain.title.to_i }.each_with_index do |domain, d_index|
      domain.subdomains.sort_by { |sd| sd.title.to_i }.each_with_index do |subdomain, index|
        subdomain.score_units.sort_by { |su| [su.title_s, su.title_i] }.each do |score_unit|
          score_unit.survey_raw_scores(survey_score).each do |raw_score|
            next unless raw_score.value

            csv << [survey.id, identifier, center.center_type, center.administration,
                    center.region, center.department, center.municipality, domain.title,
                    subdomain.title, score_unit.title, raw_score.weight(center), raw_score.value,
                    '', '', '', raw_score.response.nil? ? '' : raw_score.response&.text,
                    raw_score.response.nil? ? '' : raw_score.response&.to_s,
                    raw_score.response.nil? ? '' : raw_score.response&.to_s_es]
          end
        end
        subdomain_score = subdomain.score(survey_score)
        domain_score = domain.score(survey_score) if index == domain.subdomains.size - 1
        center_score = center.score(survey_score) if d_index == domains.size - 1 && index == domain.subdomains.size - 1
        sd_score = subdomain_score.nil? ? '' : subdomain_score
        d_score = domain_score.nil? ? '' : domain_score
        c_score = center_score.nil? ? '' : center_score
        next if sd_score.blank? && d_score.blank? && c_score.blank?

        csv << [survey.id, identifier, center.center_type, center.administration, center.region, center.department,
                center.municipality, domain.title, subdomain.title, '', '', '', sd_score, d_score, c_score, '', '', '']
      end
    end
    survey_score.score_data = csv.to_s
    survey_score.score_sum = center_score
    survey_score.save
  end

  def download
    file = Tempfile.new(title.to_s)
    CSV.open(file, 'w') do |csv|
      csv << %w[survey_id center_id center_type center_admin region department
                municipality domain subdomain score_unit score_unit_weight
                score_unit_score subdomain_score domain_score center_score
                response response_label_en response_label_es]
      survey_scores.sort_by { |ss| ss.identifier.to_i }.each do |survey_score|
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
