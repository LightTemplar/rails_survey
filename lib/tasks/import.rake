desc "Import survey(s) from CSV file"
task :import, [:filename] => :environment do |t, args|
  if Project.first.nil?
    Rake::Task['db:default_user'].reenable
    Rake::Task['db:default_user'].invoke
  end
  title = args[:filename].gsub(/.csv/, '').split('/').last.gsub(/_/, ' ').upcase
  instrument = Project.first.instruments.where(title: title).first
  unless instrument
    instrument = Instrument.create!(title: title, published: false,
      language: 'en', alignment: 'left', project_id: Project.first.id)
  end
  csv_headers = ["Question Set", "Question Id", "Question Type", "Instruction Digest",
        "Option Set Digest", "English", "Swahili",	"Amharic",	"Khmer",	"Telugu"]
  question_set = nil
  question = nil
  CSV.foreach(args[:filename], headers: true) do |row|
    instrument.reload
    unless row[0].blank?
      display = Display.where(title: row[0].strip, instrument_id: instrument.id).first
      unless display
        display = Display.create!(title: row[0].strip, mode: 'MULTIPLE',
          position: instrument.displays.size, instrument_id: instrument.id
        )
      end
      question_set = QuestionSet.where(title: row[0].strip).try(:first)
      unless question_set
        question_set = QuestionSet.create!(title: row[0].strip)
      end
      question = Question.where(question_identifier: row[1].strip).try(:first)
      unless question
        question = Question.create!(question_identifier: row[1].strip,
          question_type: row[2].strip, text: row[5].strip, question_set_id: question_set.id)
      end
      (6..9).each do |n|
        unless row[n].blank?
          QuestionTranslation.create!(question_id: question.id,
            language: Settings.languages.to_h[csv_headers[n]],
            text: row[n]
          )
        end
      end
      iq = InstrumentQuestion.where(instrument_id: instrument.id,
        identifier: row[1].strip, question_id: question.id).first
      unless iq
        iq = InstrumentQuestion.create!(instrument_id: instrument.id,
          identifier: row[1].strip, question_id: question.id, display_id:
          display.id, number_in_instrument: instrument.instrument_questions.size
        )
      end
    end
    unless row[3].blank?
      instruction = Instruction.where(title: row[3].strip).first
      unless instruction
        instruction = Instruction.create!(title: row[3].strip, text: row[5].strip)
      end
      unless question.instruction_id
        question.instruction_id = instruction.id
        question.save!
      end
    end
    unless row[4].blank?
      option_set = OptionSet.where(title: row[4].strip).try(:first)
      unless option_set
        option_set = OptionSet.create!(title: row[4].strip)
      end
      unless question.option_set_id
        question.option_set_id = option_set.id
        question.save!
      end
      option = Option.where(identifier: row[5].strip).try(:first)
      unless option
        option = Option.create!(identifier: row[5].strip, text: row[5].strip)
      end
      option_in_option_set = option_set.option_in_option_sets.where(
        option_id: option.id, option_set_id: option_set.id).try(:first)
      unless option_in_option_set
        OptionInOptionSet.create!(option_id: option.id, option_set_id: option_set.id,
          number_in_question: option_set.options.size
        )
      end
      (6..9).each do |n|
        unless row[n].blank?
          option_translation = option.translations.where(option_id: option.id,
            language: Settings.languages.to_h[csv_headers[n]], text: row[n].strip).try(:first)
          unless option_translation
            OptionTranslation.create!(option_id: option.id,
              language: Settings.languages.to_h[csv_headers[n]],
              text: row[n].strip
            )
          end
        end
      end
    end
  end
end
