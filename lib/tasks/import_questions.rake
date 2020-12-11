# frozen_string_literal: true

desc 'Import questions from CSV file'
task :import_questions, [:filename] => :environment do |_t, args|
  question_identifiers = []
  CSV.foreach(args[:filename], headers: true) do |row|
    question_identifiers << row[1].strip if !row[1].strip.blank? && row[2].strip != 'SKIP'
  end

  csv_headers = ['Question Set', 'Question Id', 'Question Type', 'Instruction Digest',
                 'Option Set Digest', 'English', 'Swahili', 'Amharic', 'Khmer', 'Telugu']
  question = nil
  option_set = nil
  folder = nil
  alphabet = ('a'..'z').to_a
  CSV.foreach(args[:filename], headers: true) do |row|
    unless row[0].blank?
      question_set = QuestionSet.where(title: row[0].strip).try(:first)
      question_set ||= QuestionSet.create!(title: row[0].strip)

      if row[2].strip == 'HEADING'
        folder = question_set.folders.where(title: row[5].strip).first
        folder ||= Folder.create!(title: row[5].strip, question_set_id: question_set.id)
        next
      end

      if row[2].strip == 'INSTRUCTIONS'
        instruction = Instruction.where(title: row[5].strip).first
        instruction ||= Instruction.create!(title: row[5].strip, text: row[5].strip)
        (6..9).each do |n|
          next if row[n].blank?

          it = instruction.instruction_translations.where(language: Settings.languages.to_h[csv_headers[n]], text: row[n].strip).first
          it ||= InstructionTranslation.create!(instruction_id: instruction.id,
                                                language: Settings.languages.to_h[csv_headers[n]], text: row[n].strip)
        end
        next
      end

      unless row[2].strip == 'SKIP'
        if folder.nil?
          folder = question_set.folders.where(title: 'Introduction').first
          folder ||= Folder.create!(title: 'Introduction', question_set_id: question_set.id)
        end
        question = Question.where(question_identifier: row[1].strip).try(:first)
        question ||= Question.create!(question_identifier: row[1].strip, question_type: row[2].strip,
                                      text: row[5].strip, question_set_id: question_set.id, folder_id: folder.id)
        (6..9).each do |n|
          next if row[n].blank?

          qt = question.translations.where(language: Settings.languages.to_h[csv_headers[n]], text: row[n]).first
          qt ||= QuestionTranslation.create!(question_id: question.id,
                                             language: Settings.languages.to_h[csv_headers[n]], text: row[n])
          next unless qt && !row[n + 4].blank?

          bt = BackTranslation.where(backtranslatable_id: qt.id, backtranslatable_type: 'QuestionTranslation', language: Settings.languages.to_h[csv_headers[n]]).first
          bt ||= BackTranslation.create!(text: row[n + 4], language: Settings.languages.to_h[csv_headers[n]],
                                         backtranslatable_id: qt.id, backtranslatable_type: 'QuestionTranslation', approved: true)
        end

        if question.question_type != 'INSTRUCTIONS'
          special_option_set = OptionSet.where(special: true).first
          special_option_set ||= OptionSet.create!(title: 'Special Option Set', special: true)
          %w[DK RF MI NA].each_with_index do |sp, index|
            special_option = Option.where(identifier: sp).first
            special_option ||= Option.create!(identifier: sp, text: sp)
            oios = OptionInOptionSet.where(option_id: special_option.id, option_set_id: special_option_set.id).first
            next if oios

            OptionInOptionSet.create!(option_id: special_option.id, option_set_id: special_option_set.id,
                                      special: true, number_in_question: index)
          end
          question.update_columns(special_option_set_id: special_option_set.id)
        end
      end
    end

    if !row[3].blank? && row[4].blank?
      instruction = Instruction.where(title: row[3].strip).first
      instruction ||= Instruction.create!(title: row[3].strip, text: row[5].strip)
      question.update_columns(instruction_id: instruction.id) unless question.instruction_id
    end

    if !row[3].blank? && !row[4].blank?
      instruction = Instruction.where(title: row[3].strip).first
      instruction ||= Instruction.create!(title: row[3].strip, text: row[5].strip)
      os = OptionSet.where(title: row[4].strip).first
      if os && os.instruction_id.nil?
        os.update_columns(instruction_id: instruction.id)
      else
        OptionSet.create!(title: row[4].strip, instruction_id: instruction.id) unless os
      end
    end

    if !row[4].blank? && row[3].blank?
      option_set = OptionSet.where(title: row[4].strip).first
      option_set ||= OptionSet.create!(title: row[4].strip)
      question.update_columns(option_set_id: option_set.id) unless question.option_set_id
      option = Option.where(identifier: row[5].strip).try(:first)
      option ||= Option.create!(identifier: row[5].strip, text: row[5].strip)
      option_in_option_set = option_set.option_in_option_sets.where(
        option_id: option.id, option_set_id: option_set.id
      ).try(:first)
      unless option_in_option_set
        OptionInOptionSet.create!(option_id: option.id, option_set_id: option_set.id,
                                  number_in_question: option_set.options.size)
      end
      (6..9).each do |n|
        next if row[n].blank?

        ot = option.translations.where(language: Settings.languages.to_h[csv_headers[n]], text: row[n].strip).try(:first)
        next if ot

        ot = OptionTranslation.create!(option_id: option.id,
                                       language: Settings.languages.to_h[csv_headers[n]], text: row[n].strip)
        next unless ot && !row[n + 4].blank?

        bt = BackTranslation.where(
          backtranslatable_id: ot.id, backtranslatable_type: 'OptionTranslation', language: Settings.languages.to_h[csv_headers[n]]
        ).first
        bt ||= BackTranslation.create!(text: row[n + 4], language: Settings.languages.to_h[csv_headers[n]],
                                       backtranslatable_id: ot.id, backtranslatable_type: 'OptionTranslation', approved: true)
      end
    end
  end
  OptionSet.without_option_in_option_sets.delete_all
end
