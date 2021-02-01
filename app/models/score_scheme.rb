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
  has_many :score_data, through: :survey_scores
  has_many :score_scheme_centers, dependent: :destroy
  has_many :centers, through: :score_scheme_centers
  has_many :red_flags

  delegate :project, to: :instrument

  acts_as_paranoid

  validates :title, presence: true, uniqueness: { scope: [:instrument_id] }

  def distinct_score_units
    by_title = score_units.group_by(&:title)
    unique_units = []
    by_title.each do |_title, score_unit|
      unique_units << score_unit[0]
    end
    unique_units
  end

  def copy
    duplicate = dup
    duplicate.title = "#{title} copy"
    duplicate.save!
    domains.each do |domain|
      dup_domain = domain.dup
      dup_domain.score_scheme_id = duplicate.id
      dup_domain.save!
      domain.subdomains.each do |subdomain|
        dup_sub = subdomain.dup
        dup_sub.domain_id = dup_domain.id
        dup_sub.save!
        subdomain.score_units.each do |score_unit|
          dup_su = score_unit.dup
          dup_su.subdomain_id = dup_sub.id
          dup_su.save!
          score_unit.score_unit_questions.each do |suq|
            dup_suq = suq.dup
            dup_suq.score_unit_id = dup_su.id
            dup_suq.save!
            suq.option_scores.each do |os|
              dup_os = os.dup
              dup_os.score_unit_question_id = dup_suq.id
              dup_os.save!
            end
          end
        end
      end
    end
    centers.each do |center|
      ScoreSchemeCenter.create!(center_id: center.id, score_scheme_id: duplicate.id)
    end
  end

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
        wb.add_worksheet(name: domain.title_name) do |sheet|
          tab_color = SecureRandom.hex(3)
          sheet.sheet_pr.tab_color = tab_color
          sheet.add_row ['', '', '', '', domain.title_name, '', '', '', '', ''],
                        style: wb.styles.add_style(b: true, alignment: { horizontal: :center, vertical: :center },
                                                   border: b_style, bg_color: tab_color), height: row_height
          sheet.add_row %w[Identifier Subdomain Weight Code Question Base Score Type Translation Notes],
                        style: wb.styles.add_style(alignment: { horizontal: :center, vertical: :center }, border: b_style),
                        height: row_height
          domain.subdomains.each do |subdomain|
            subdomain.score_units.sort_by { |su| [su.str_title, su.int_title] }.each do |unit|
              unit.score_unit_questions.each_with_index do |suq, index|
                q_style = index == unit.score_unit_questions.size - 1 && suq.option_scores.empty? ?
                [c_border, c_border, c_border, c_border, b_question_style, c_border, c_border, border,
                 b_question_style, b_option_style] : [c_style, c_style, c_style, c_style, question_style, c_style,
                                                      c_style, c_style, question_style, option_style]
                sheet.add_row [unit.title, subdomain.title_name, unit.weight,
                               suq.question_identifier, html_decode(full_sanitize(suq.instrument_question.text)),
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
      ScoreGeneratorWorker.perform_async(id, survey.id)
    end
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

  def generate_unit_scores(survey, survey_score)
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
      filename = "#{title.split.join('_')}_#{weight}.csv"
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

    zip_file = Tempfile.new("#{title}_#{Time.now.to_i}.zip")
    Zip::File.open(zip_file, Zip::File::CREATE) do |zipfile|
      files.each do |filename, file|
        zipfile.add(filename, file.path)
      end
    end
    zip_file
  end
end
