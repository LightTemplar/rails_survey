desc 'Import survey(s) from CSV file'
task :import, [:filename] => :environment do |_t, args|
  if Project.first.nil?
    Rake::Task['db:default_user'].reenable
    Rake::Task['db:default_user'].invoke
  end
  title = args[:filename].gsub(/.csv/, '').split('/').last.gsub(/_/, ' ').upcase
  instrument = Project.first.instruments.where(title: title).first
  instrument ||= Instrument.create!(title: title, published: false, language: 'en',
    alignment: 'left', project_id: Project.first.id)
  question_identifiers = []
  CSV.foreach(args[:filename], headers: true) do |row|
    if !row[1].strip.blank? && row[2].strip != 'SKIP'
      question_identifiers << row[1].strip
    end
  end

  csv_headers = ['Question Set', 'Question Id', 'Question Type', 'Instruction Digest',
                 'Option Set Digest', 'English', 'Swahili', 'Amharic', 'Khmer', 'Telugu']
  question = nil
  option_set = nil
  display = nil
  folder = nil
  alphabet = ('a'..'z').to_a
  CSV.foreach(args[:filename], headers: true) do |row|
    instrument.reload

    unless row[0].blank?
      question_set = QuestionSet.where(title: row[0].strip).try(:first)
      question_set ||= QuestionSet.create!(title: row[0].strip)
      section = Section.where(title: row[0].strip, instrument_id: instrument.id).try(:first)
      section ||= Section.create!(title: row[0].strip, instrument_id: instrument.id)

      if row[2].strip == 'HEADING'
        display = Display.where(title: row[5].strip, instrument_id: instrument.id).first
        display ||= Display.create!(title: row[5].strip, mode: 'MULTIPLE', section_id: section.id,
                                    position: instrument.displays.size + 1, instrument_id: instrument.id)
        folder = Folder.where(title: row[5].strip, question_set_id: question_set.id).first
        folder ||= Folder.create!(title: row[5].strip, question_set_id: question_set.id)
        next
      end

      if row[2].strip == 'INSTRUCTIONS'
        instruction = Instruction.where(title: row[5].strip).first
        instruction ||= Instruction.create!(title: row[5].strip, text: row[5].strip)
        display_instruction = DisplayInstruction.where(display_id: display.id, instruction_id: instruction.id).first
        display_instruction ||= DisplayInstruction.create!(display_id: display.id, instruction_id: instruction.id)
        (6..9).each do |n|
          next if row[n].blank?
          it = InstructionTranslation.where(instruction_id: instruction.id,
            language: Settings.languages.to_h[csv_headers[n]], text: row[n].strip).first
          it ||= InstructionTranslation.create!(instruction_id: instruction.id,
            language: Settings.languages.to_h[csv_headers[n]], text: row[n].strip)
        end
        next
      end

      unless row[2].strip == 'SKIP'
        if folder.nil?
          folder = Folder.where(title: 'Introduction', question_set_id: question_set.id).first
          folder ||= Folder.create!(title: 'Introduction', question_set_id: question_set.id)
        end
        if display.nil?
          display = Display.where(title: 'Introduction', instrument_id: instrument.id).first
          display ||= Display.create!(title: 'Introduction', mode: 'MULTIPLE', section_id: section.id,
            position: instrument.displays.size + 1, instrument_id: instrument.id)
        end
        question = Question.where(question_identifier: row[1].strip).try(:first)
        question ||= Question.create!(question_identifier: row[1].strip, question_type: row[2].strip,
          text: row[5].strip, question_set_id: question_set.id, folder_id: folder.id)
        (6..9).each do |n|
          next if row[n].blank?
          qt = QuestionTranslation.where(question_id: question.id,
            language: Settings.languages.to_h[csv_headers[n]], text: row[n]).first
          qt ||= QuestionTranslation.create!(question_id: question.id,
            language: Settings.languages.to_h[csv_headers[n]], text: row[n])
          if qt && !row[n + 4].blank?
            bt = BackTranslation.where(text: row[n + 4], language: Settings.languages.to_h[csv_headers[n]],
              backtranslatable_id: qt.id, backtranslatable_type: 'QuestionTranslation').first
            bt ||= BackTranslation.create!(text: row[n + 4], language: Settings.languages.to_h[csv_headers[n]],
              backtranslatable_id: qt.id, backtranslatable_type: 'QuestionTranslation', approved: true)
          end
        end
        iq = InstrumentQuestion.where(instrument_id: instrument.id, identifier: row[1].strip,
          question_id: question.id).first
        if iq
          InstrumentQuestion.create!(instrument_id: instrument.id, identifier: "#{row[1].strip}_#{Time.now.to_i}",
            question_id: question.id, display_id: display.id, number_in_instrument: instrument.instrument_questions.size + 1)
        else
          InstrumentQuestion.create!(instrument_id: instrument.id, identifier: row[1].strip,
            question_id: question.id, display_id: display.id, number_in_instrument: instrument.instrument_questions.size + 1)
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
          question.special_option_set_id = special_option_set.id
          question.save!
        end
      end
    end

    if !row[3].blank? && row[4].blank?
      instruction = Instruction.where(title: row[3].strip).first
      instruction ||= Instruction.create!(title: row[3].strip, text: row[5].strip)
      unless question.instruction_id
        question.instruction_id = instruction.id
        question.save!
      end
    end

    if !row[3].blank? && !row[4].blank?
      instruction = Instruction.where(title: row[3].strip).first
      instruction ||= Instruction.create!(title: row[3].strip, text: row[5].strip)
      os = OptionSet.where(title: row[4].strip).first
      if os && os.instruction_id.nil?
        os.instruction_id = instruction.id
        os.save!
      else
        OptionSet.create!(title: row[4].strip, instruction_id: instruction.id)
      end
    end

    if !row[4].blank? && row[3].blank?
      option_set = OptionSet.where(title: row[4].strip).first
      option_set ||= OptionSet.create!(title: row[4].strip)
      unless question.option_set_id
        question.option_set_id = option_set.id
        question.save!
      end
      option = Option.where(identifier: row[5].strip).try(:first)
      option ||= Option.create!(identifier: row[5].strip, text: row[5].strip)
      option_in_option_set = option_set.option_in_option_sets.where(
          option_id: option.id, option_set_id: option_set.id).try(:first)
      unless option_in_option_set
        OptionInOptionSet.create!(option_id: option.id, option_set_id: option_set.id,
                                  number_in_question: option_set.options.size)
      end
      (6..9).each do |n|
        next if row[n].blank?
        ot = option.translations.where(option_id: option.id,
          language: Settings.languages.to_h[csv_headers[n]], text: row[n].strip).try(:first)
        next if ot
        ot = OptionTranslation.create!(option_id: option.id,
          language: Settings.languages.to_h[csv_headers[n]], text: row[n].strip)
        if ot && !row[n + 4].blank?
          bt = BackTranslation.where(text: row[n + 4], language: Settings.languages.to_h[csv_headers[n]],
            backtranslatable_id: ot.id, backtranslatable_type: 'OptionTranslation').first
          bt ||= BackTranslation.create!(text: row[n + 4], language: Settings.languages.to_h[csv_headers[n]],
            backtranslatable_id: ot.id, backtranslatable_type: 'OptionTranslation', approved: true)
        end
      end
    end

    if row[2].strip == 'SKIP'
      options = option_set.options
      skip_text = row[5].strip
      next_question_identifier = nil
      skip_parts = nil
      question_identifier = question.question_identifier
      # puts "question_identifier: #{question_identifier}"
      if skip_text.include? 'go to'
        skip_parts = skip_text.split('go to')
        next_question_identifier = skip_parts[1].strip.chomp('.')
        if next_question_identifier[0..1] == 'q:'
          next_question_identifier = next_question_identifier[2..-1]
        end
      elsif skip_text.include? 'skip next question'
        cqii = question_identifiers.index(question_identifier) + 2
        next_question_identifier = question_identifiers[cqii]
        skip_parts = skip_text.split('skip next question')
      end
      if next_question_identifier && !question_identifiers.include?(next_question_identifier)
        puts "Enter manually for question #{question_identifier}"
        next_question_identifier = nil
      end
      if skip_parts.nil?
        puts "Enter manually for question #{question_identifier}"
      end
      if !skip_parts.nil? && skip_parts[0].include?('OR')
        skip_determinants = skip_parts[0].strip.split('OR')
        option_identifier = nil
        skip_determinants.each do |part|
          choice = part[/\[(.*?)\]/, 1]
          choice ||= part[/\((.*?)\)/, 1]
          if alphabet.index(choice)
            option_identifier = options[alphabet.index(choice)].identifier
          elsif choice # Not nil
            special_option = Option.where(identifier: choice).try(:first)
            special_option ||= Option.create!(identifier: choice, text: choice)
            option_identifier = special_option.identifier
          else
            puts "Enter manually for question #{question_identifier}"
          end
          next unless question_identifier && option_identifier && next_question_identifier
          skip_pattern = SkipPattern.where(question_identifier: question_identifier,
            option_identifier: option_identifier, next_question_identifier: next_question_identifier).first
          next if skip_pattern
          SkipPattern.create!(question_identifier: question_identifier, option_identifier: option_identifier,
            next_question_identifier: next_question_identifier)
        end
      end
    end
  end
  instrument.set_skip_patterns
  OptionSet.without_option_in_option_sets.delete_all
  Instrument.create_translations
end
