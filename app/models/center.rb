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
  has_many :domain_scores, through: :score_data
  has_many :subdomain_scores, through: :score_data
  has_many :raw_scores, through: :survey_scores
  has_many :surveys, through: :survey_scores

  validates :identifier, presence: true, allow_blank: false
  validates :name, presence: true, allow_blank: false
  validates :center_type, presence: true, allow_blank: false

  default_scope { order :identifier }

  def ss_survey_scores(score_scheme_id)
    survey_scores.where(score_scheme_id: score_scheme_id)
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

  def red_flag_text(score_scheme, responses)
    red_flags = []
    responses.each do |response|
      red_flags << full_sanitizer.sanitize(response.red_flag_descriptions(score_scheme)).strip if response.is_red_flag?(score_scheme)
    end
    red_flags.uniq.join('; ')
  end

  def responses(css)
    uuids = css.map { |ss| ss.survey.uuid }
    Response.where(survey_uuid: uuids)
  end

  def unit_raw_score(urs)
    arr = urs.reject { |e| e.value.nil? }
    arr.empty? ? '' : arr.inject(0.0) { |sum, e| sum + e.value } / arr.size
  end

  def average_score(sds)
    arr = sds.reject { |e| e.score_sum.nil? }
    arr.empty? ? '' : arr.inject(0.0) { |sum, e| sum + e.score_sum } / arr.size
  end

  def response_text(suq, responses, skipped)
    arr = []
    if !suq.instrument_question.select_one_variant? &&
       !suq.instrument_question.select_multiple_variant? &&
       !suq.instrument_question.list_of_boxes_variant?
      responses.each do |r|
        arr << r.text unless r.text.blank?
      end
    else
      texts = responses.reject { |res| res.text.blank? }
      return unless texts.empty?
    end

    responses.each do |r|
      arr << r.special_response unless r.special_response.blank?
    end
    if arr.empty?
      responses.each do |r|
        arr << 'SK' if skipped.include?(r.question_identifier)
      end
    end
    if arr.empty?
      responses.each do |r|
        arr << 'MI' if r.empty?
      end
    end
    arr.uniq.join(' | ')
  end

  def selection_set(responses, suq)
    list = []
    arr = responses.reject { |e| e.text.blank? }
    arr = arr.map(&:text).uniq
    if suq.instrument_question.select_one_variant? || suq.instrument_question.select_multiple_variant?
      arr.each do |item|
        item.split(',').each do |r|
          list << r.to_i
        end
      end
    end
    list.uniq
  end

  def list_set(responses, suq)
    list = []
    arr = responses.reject { |e| e.text.blank? }
    arr = arr.map(&:text).uniq
    if suq.instrument_question.list_of_boxes_variant?
      arr.each do |item|
        item.split(',').each_with_index do |r, i|
          list[i] = r
        end
      end
    end
    list
  end

  def choice_text(suq, selected_indices, list_indices, index)
    if suq.instrument_question.list_of_boxes_variant?
      list_indices[index]
    else
      selected_indices.include?(index) ? '✔️' : ''
    end
  end

  def skipped_questions(css)
    list = []
    css.each do |ss|
      list << ss.survey.skipped
    end
    list = list.flatten.uniq
  end

  def add_center_sheet(wb, c_score_data, b_style, language)
    wb.add_worksheet(name: I18n.t('center.center', locale: language)) do |sheet|
      tab_color = colors[0]
      sheet.sheet_pr.tab_color = tab_color
      sheet.add_row center_header(language),
                    style: wb.styles.add_style(b: true, border: b_style, alignment: { horizontal: :center }, bg_color: tab_color),
                    height: row_height
      sheet.add_row [identifier, name, center_type, administration, region, department, municipality, average_score(c_score_data)],
                    style: wb.styles.add_style(alignment: { horizontal: :center }), height: row_height
    end
  end

  def center_header(language)
    %w[identifier name type administration region department municipality score]
      .map { |item| I18n.t("center.#{item}", locale: language) }
  end

  def colors
    %w[9C6ACB 6DD865 85B2C9 559F93 68D49A B39358 4DB2E9 5DC15E 7BC676 75AC77 B966E3 D0E0FC 85AFCA E8BA78]
  end

  def row_height
    25
  end

  def add_title_rows(domain, wb, sheet, tab_color, translate, language)
    sheet.sheet_pr.tab_color = tab_color
    sheet.add_row ['', '', '', '', domain_label(translate, domain, language), '', '', '', '', '', '', '', ''],
                  style: wb.styles.add_style(b: true, alignment: { horizontal: :center, vertical: :center },
                                             bg_color: tab_color), height: row_height
    sheet.add_row %w[identifier subdomain weight code question base points operation response score subdomain_score red_flags notes]
      .map { |item| I18n.t("center.#{item}", locale: language) },
                  style: wb.styles.add_style(b: true, alignment: { horizontal: :center, vertical: :center },
                                             bg_color: tab_color), height: row_height
  end

  def domain_label(translate, domain, language)
    label = full_sanitize(domain.translated_title_name(language)) if translate
    label.blank? ? domain.title_name : label
  end

  def subdomain_label(translate, subdomain, language)
    label = full_sanitize(subdomain.translated_title_name(language)) if translate
    label.blank? ? subdomain.title_name : label
  end

  def formatted_scores(score_scheme, language)
    translate = score_scheme.instrument.language != language
    file = Tempfile.new(score_scheme.title)
    black = '000000'
    red = 'FF0000'
    Axlsx::Package.new do |p|
      wb = p.workbook
      b_style = { style: :thin, color: black, edges: [:bottom] }
      wrap_text = { wrap_text: true }
      border = wb.styles.add_style(border: b_style)
      wrap_style = wb.styles.add_style(alignment: wrap_text)
      b_wrap_style = wb.styles.add_style(alignment: wrap_text, border: b_style)
      question_style = wb.styles.add_style(b: true, alignment: wrap_text)
      option_style = wb.styles.add_style(alignment: wrap_text)
      b_question_style = wb.styles.add_style(b: true, alignment: wrap_text, border: b_style)
      score_style = wb.styles.add_style(b: true, alignment: { horizontal: :center, wrap_text: true })
      rf_style = wb.styles.add_style(b: true, alignment: wrap_text, fg_color: red)
      b_rf_style = wb.styles.add_style(b: true, alignment: wrap_text, fg_color: red, border: b_style)
      b_option_style = wb.styles.add_style(alignment: wrap_text, border: b_style)
      c_style = wb.styles.add_style(alignment: { horizontal: :center })
      c_border = wb.styles.add_style(alignment: { horizontal: :center }, border: b_style)
      css = survey_scores.where(score_scheme_id: score_scheme.id)
      r_scores = raw_scores.where(survey_score_id: css.pluck(:id))
      responses = responses(css)
      c_score_data = score_data.where(survey_score_id: css.pluck(:id)).where(weight: nil).where(operator: nil)
      skipped = skipped_questions(css)
      add_center_sheet(wb, c_score_data, b_style, language)
      score_scheme.domains.sort_by { |domain| domain.title.to_i }.each do |domain|
        wb.add_worksheet(name: domain_label(translate, domain, language).truncate(31)) do |sheet|
          tab_color = colors[domain.title.to_i]
          add_title_rows(domain, wb, sheet, tab_color, translate, language)
          ds = domain_scores.where(score_datum_id: c_score_data.pluck(:id)).where(domain_id: domain.id)
          domain.subdomains.each do |subdomain|
            sds = subdomain_scores.where(score_datum_id: c_score_data.pluck(:id)).where(subdomain_id: subdomain.id)
            subdomain.score_units.sort_by { |su| [su.str_title, su.int_title] }.each do |unit|
              urs = r_scores.where(score_unit_id: unit.id)
              unit.score_unit_questions.each_with_index do |suq, index|
                suq_responses = responses.where(question_identifier: suq.question_identifier)
                options = suq.instrument_question.all_non_special_options
                q_style = index == unit.score_unit_questions.size - 1 && options.empty? ?
                [c_border, b_wrap_style, c_border, c_border, b_question_style, c_border, c_border, border, border,
                 b_question_style, b_question_style, b_rf_style, b_option_style] :
                 [c_style, wrap_style, c_style, c_style, question_style, c_style, c_style, c_style, c_style,
                  score_style, question_style, rf_style, option_style]
                sheet.add_row [unit.title, subdomain_label(translate, subdomain, language), unit.weight,
                               suq.question_identifier, translate ?
                               full_sanitize(suq.instrument_question.translations.find_by_language(language)&.text) :
                               html_decode(full_sanitize(suq.instrument_question.text)),
                               unit.base_point_score == 0.0 ? '' : unit.base_point_score, '', unit.score_type,
                               response_text(suq, suq_responses, skipped),
                               unit_raw_score(urs), '', red_flag_text(score_scheme, suq_responses),
                               html_decode(full_sanitize(unit.notes))], style: q_style
                sheet.column_widths nil, nil, nil, nil, 50, nil, nil, nil, nil, nil, nil, 30, 50
                selected_indices = selection_set(suq_responses, suq)
                list_indices = list_set(suq_responses, suq)
                options.each_with_index do |option, index|
                  o_style = index == options.size - 1 ? [border, border, border, c_border, b_option_style, border, c_border,
                                                         c_border, c_border, c_border, c_border, b_option_style, b_option_style] :
                                                         [nil, nil, nil, c_style, option_style, nil, c_style, c_style, c_style,
                                                          c_style, c_style, option_style, option_style]
                  sheet.add_row ['', '', '', index, translate ? full_sanitize(option.translations.find_by_language(language)&.text) :
                    full_sanitizer.sanitize(option.text), '', unit.score_type == 'SUM' && suq.option_score(option) ? "(#{format('%+0.1f', suq.option_score(option)&.value)})" :
                     suq.option_score(option)&.value, '', choice_text(suq, selected_indices, list_indices, index), '', '', '',
                                 html_decode(full_sanitize(suq.option_score(option)&.notes))], style: o_style
                  sheet.column_widths nil, nil, nil, nil, 50, nil, nil, nil, nil, nil, nil, 30, 50
                end
              end
            end
            sheet.add_row ['', subdomain.title_name, '', '', '', '', '', '', '', '', average_score(sds), '', ''],
                          style: wb.styles.add_style(b: true, border: b_style, bg_color: tab_color,
                                                     alignment: { horizontal: :center, vertical: :center }),
                          height: row_height
          end
          sheet.add_row ['Domain Score', average_score(ds)],
                        style: wb.styles.add_style(b: true, border: b_style), height: row_height
        end
      end
      p.serialize(file.path)
    end
    file
  end
end
