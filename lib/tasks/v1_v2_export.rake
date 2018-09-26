desc 'Export to CSV files compatible with v2'
task v1_v2_export: :environment do
  require 'csv'
  require 'digest'

  headers = ["question_set", "id", "question_type",
    "instruction_digest", "option_set_digest", "en", "es"]
  CSV.open("exports.csv", "wb") do |csv|
    csv << headers
    project = Project.find(9)
    project.instruments.each do |instrument|
      instrument.questions.each do |question|
        qs = ""
        if question.section && question.section.title
          qs = question.section.title
        else
          qs = question.instrument.title
        end
        instruction_digest = nil
        if question.question_type == 'INSTRUCTION'
          instruction_digest = Digest::SHA256.hexdigest(question.text)
        end
        es = question.translations.where(language: 'es').first.try(:text)
        row = [qs, question.question_identifier,
          question.question_type, instruction_digest, "", question.text, es]
        csv << row
        if question.options.size > 0
          osd = Digest::SHA256.hexdigest(question.options.pluck(:text).join(','))
          question.options.each do |option|
            row = ["", question.question_identifier,
              "", "", osd, option.text, option.translations.where(language: 'es').first.try(:text)]
            csv << row
          end
        end
      end
    end
  end
end
