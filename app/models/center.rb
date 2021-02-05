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
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Center < ApplicationRecord
  include Scoreable
  include Sanitizer
  include Sanitizable
  has_many :score_scheme_centers, dependent: :destroy
  has_many :score_schemes, through: :score_scheme_centers
  has_many :survey_scores, foreign_key: :identifier, primary_key: :identifier
  has_many :score_data, through: :survey_scores

  validates :identifier, presence: true, allow_blank: false
  validates :name, presence: true, allow_blank: false
  validates :center_type, presence: true, allow_blank: false

  default_scope { order :identifier }

  def survey_count(score_scheme_id)
    survey_scores.where(score_scheme_id: score_scheme_id).size
  end

  def self.download(score_scheme)
    weights = score_scheme.score_data.pluck(:weight).uniq
    files = {}
    weights.each do |weight|
      filename = "#{score_scheme.title.split.join('_')}_center_scores_#{weight}.csv"
      file = Tempfile.new(filename)
      csv = []
      score_scheme.centers.sort_by { |c| c.identifier.to_i }.each do |center|
        css = center.survey_scores.where(score_scheme_id: score_scheme.id)
        if css.size > 1
          domain_scores = {}
          subdomain_scores = {}
          survey_ids = []
          cds = []
          css.each do |survey_score|
            score_datum = survey_score.score_data.where(weight: weight).first
            next if score_datum.nil? || score_datum.content.nil?

            survey_ids << survey_score.survey_id
            data = []
            JSON.parse(score_datum.content).each { |arr| data << arr }
            data.each do |row|
              sd_scores = subdomain_scores[row[8]]
              sd_scores = [] if sd_scores.nil?
              sd_scores << row[12] unless row[12].blank?
              subdomain_scores[row[8]] = sd_scores

              d_scores = domain_scores[row[7]]
              d_scores = [] if d_scores.nil?
              d_scores << row[13] unless row[13].blank?
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
                      subdomain_score.nil? || subdomain_score.nan? ? '' : subdomain_score.round(2),
                      domain_score.nil? || domain_score.nan? ? '' : domain_score.round(2),
                      center_score.nil? || center_score.nan? ? '' : center_score.round(2)]
            end
          end
        elsif css.size == 1
          score_datum = css[0].score_data.where(weight: weight).first
          if !score_datum.nil? && !score_datum.content.nil?
            data = []
            JSON.parse(score_datum.content).each { |arr| data << arr }
            data.each do |row|
              next if (row[12].blank? && row[13].blank? && row[14].blank?) && !row[9].blank?

              csv << [center.identifier, center.center_type, center.administration,
                      center.region, center.department, center.municipality,
                      row[0], row[7], row[8], row[12], row[13], row[14]]
            end
          end
        end
      end

      CSV.open(file, 'w') do |row|
        row << %w[center_id center_type center_admin region department municipality
                  survey_ids domain subdomain subdomain_score domain_score center_score]
        csv.each do |data|
          row << data
        end
      end
      files[filename] = file
    end

    zip_file = Tempfile.new("#{score_scheme.title.split.join('_')}_#{Time.now.to_i}.zip")
    Zip::File.open(zip_file, Zip::File::CREATE) do |zipfile|
      files.each do |filename, file|
        zipfile.add(filename, file.path)
      end
    end
    zip_file
  end

  def red_flags(score_scheme)
    file = Tempfile.new(identifier)
    CSV.open(file, 'w') do |row|
      row << %w[center_id survey_id question_id response description]
      survey_scores.where(score_scheme_id: score_scheme.id).each do |survey_score|
        survey_score.survey.responses.each do |response|
          next unless response.is_red_flag?(score_scheme)

          row << [identifier, survey_score.survey.id, response.question_identifier,
                  full_sanitizer.sanitize(response.red_flag_response(score_scheme)).strip,
                  full_sanitizer.sanitize(response.red_flag_descriptions(score_scheme)).strip]
        end
      end
    end
    file
  end

  def red_flag_text(score_scheme, responses, suq)
    red_flags = []
    responses.where(question_identifier: suq.question_identifier).each do |response|
      red_flags << full_sanitizer.sanitize(response.red_flag_descriptions(score_scheme)).strip if response.is_red_flag?(score_scheme)
    end
    red_flags.join('; ')
  end

  def formatted_scores(score_scheme, language)
    translate = score_scheme.instrument.language != language
    file = Tempfile.new(score_scheme.title)
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
      css = survey_scores.where(score_scheme_id: score_scheme.id)
      score_scheme.domains.sort_by { |domain| domain.title.to_i }.each do |domain|
        is_last_domain = score_scheme.domains.last.id == domain.id
        wb.add_worksheet(name: domain.title_name) do |sheet|
          tab_color = SecureRandom.hex(3)
          sheet.sheet_pr.tab_color = tab_color
          sheet.add_row ['', '', '', '', domain.title_name, '', '', '', '', '', '', '', ''],
                        style: wb.styles.add_style(b: true, alignment: { horizontal: :center, vertical: :center },
                                                   border: b_style, bg_color: tab_color), height: row_height
          sheet.add_row %w[Identifier Subdomain Weight Code Question Base Score Type Response ActualScore SubdomainScore RedFlags Notes],
                        style: wb.styles.add_style(alignment: { horizontal: :center, vertical: :center }, border: b_style),
                        height: row_height
          # start
          css.each do |center_survey_score|
            r_scores = center_survey_score.raw_scores
            responses = center_survey_score.survey.responses
            center_survey_score.score_data.where(weight: nil).where(operator: nil).each do |score_datum|
              ds = score_datum.domain_scores.where(domain_id: domain.id)
              domain.subdomains.each do |subdomain|
                is_last_subdomain = domain.subdomains.last.id == subdomain.id
                sds = score_datum.subdomain_scores.where(subdomain_id: subdomain.id)
                subdomain.score_units.sort_by { |su| [su.str_title, su.int_title] }.each do |unit|
                  urs = r_scores.where(score_unit_id: unit.id)
                  unit.score_unit_questions.each_with_index do |suq, index|
                    q_style = index == unit.score_unit_questions.size - 1 && suq.option_scores.empty? ?
                    [c_border, c_border, c_border, c_border, b_question_style, c_border, c_border, border, border,
                     b_question_style, b_question_style, b_question_style, b_option_style] :
                     [c_style, c_style, c_style, c_style, question_style, c_style, c_style, c_style, c_style,
                      question_style, question_style, question_style, option_style]
                    sheet.add_row [unit.title, subdomain.title_name, unit.weight,
                                   suq.question_identifier, translate ?
                                   full_sanitize(suq.instrument_question.translations.find_by_language(language)&.text) :
                                   html_decode(full_sanitize(suq.instrument_question.text)),
                                   unit.base_point_score == 0.0 ? '' : unit.base_point_score, '', unit.score_type,
                                   responses.where(question_identifier: suq.question_identifier).map(&:text).join(' ; '),
                                   urs.map { |rs| rs.value.to_s }.join(' ; '), '',
                                   red_flag_text(score_scheme, responses, suq),
                                   html_decode(full_sanitize(unit.notes))], style: q_style
                    sheet.column_widths nil, nil, nil, nil, 50, nil, nil, nil, 15, 15, 15, 30, 50
                    suq.option_scores.each_with_index do |score, index|
                      o_style = index == suq.option_scores.size - 1 ?
                      [border, border, border, c_border, b_option_style, border, c_border, c_border, c_border, c_border, c_border,
                       b_option_style, b_option_style] : [nil, nil, nil, c_style, option_style, nil,
                                                          c_style, c_style, c_style, c_style, c_style, option_style, option_style]
                      sheet.add_row ['', '', '', suq.option_index(score.option), translate ? full_sanitize(
                        score.option.translations.find_by_language(language)&.text
                      ) : full_sanitizer.sanitize(score.option.text), '',
                                     unit.score_type == 'SUM' ? "(#{format('%+0.1f', score.value)})" : score.value,
                                     '', '', '', '', '', html_decode(full_sanitize(score.notes))], style: o_style
                      sheet.column_widths nil, nil, nil, nil, 50, nil, nil, nil, 15, 15, 15, 30, 50
                    end
                  end
                end
                sheet.add_row ['', '', '', '', '', '', '', '', '', '', sds.map { |e| e.score_sum.to_s }.join(' ; '), '', ''],
                              style: wb.styles.add_style(b: true, border: b_style), height: row_height
              end
              sheet.add_row ['Domain Score', ds.map { |e| e.score_sum.to_s }.join(' ; ')],
                            style: wb.styles.add_style(b: true, border: b_style), height: row_height
            end
          end
          # end
        end
      end
      p.serialize(file.path)
    end
    file
  end
end
